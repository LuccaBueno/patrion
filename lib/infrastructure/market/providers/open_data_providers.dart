import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:clock/clock.dart';
import 'package:path/path.dart' as p;

import '../../../application/market/market_ports.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/time/instant_format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/provider_catalog.dart';
import '../market_http.dart';
import 'parse.dart';

/// Tesouro Transparente: preços e taxas do Tesouro Direto
/// (`FONTES_DE_DADOS.md` §2.6). Um CSV com todos os títulos e todo o
/// histórico; o arquivo baixado vai para o cache e é apagado depois de lido.
class TesouroProvider implements TreasuryProvider {
  TesouroProvider(
    this._http, {
    required this.cacheDir,
    Clock wallClock = const Clock(),
  }) : _clock = wallClock;

  final MarketHttp _http;
  final String cacheDir;
  final Clock _clock;

  static final url = Uri.https(
    'www.tesourotransparente.gov.br',
    '/ckan/dataset/df56aa42-484a-4a59-8184-7676580c81e3/resource/'
        '796d2059-14e9-44e3-80c9-2d9e30b405c1/download/'
        'precotaxatesourodireto.csv',
  );

  @override
  String get code => ProviderCatalog.tesouro.code;

  @override
  Future<List<TreasuryPrice>> prices({required LocalDate from}) async {
    Directory(cacheDir).createSync(recursive: true);
    final file = p.join(cacheDir, 'tesouro_precos.csv');
    try {
      await _http.download(code, url, file);
      final text = const Utf8Codec(allowMalformed: true)
          .decode(File(file).readAsBytesSync());
      return parse(text, from: from, collectedAt: formatInstant(_clock.now()));
    } finally {
      final f = File(file);
      if (f.existsSync()) f.deleteSync();
    }
  }

  /// `Tipo Titulo;Data Vencimento;Data Base;Taxa Compra Manha;Taxa Venda
  /// Manha;PU Compra Manha;PU Venda Manha;PU Base Manha`, com decimais com
  /// vírgula.
  static List<TreasuryPrice> parse(
    String text, {
    required LocalDate from,
    required String collectedAt,
  }) {
    const name = 'Tesouro Transparente';
    final lines = const LineSplitter().convert(text);
    if (lines.isEmpty || !lines.first.startsWith('Tipo Titulo')) {
      MarketParse.invalid(name, 'cabeçalho diferente');
    }
    final result = <TreasuryPrice>[];
    for (final line in lines.skip(1)) {
      final c = line.split(';');
      if (c.length < 8) continue;
      final maturity = MarketParse.brDate(c[1]);
      final ref = MarketParse.brDate(c[2]);
      if (maturity == null || ref == null || ref.isBefore(from)) continue;
      result.add(
        TreasuryPrice(
          title: c[0].trim(),
          maturity: maturity,
          refDate: ref,
          buyRate: MarketParse.decimal(c[3], brazilian: true),
          sellRate: MarketParse.decimal(c[4], brazilian: true),
          buyPu: MarketParse.decimal(c[5], brazilian: true),
          sellPu: MarketParse.decimal(c[6], brazilian: true),
          basePu: MarketParse.decimal(c[7], brazilian: true),
          source: ProviderCatalog.tesouro.code,
          collectedAt: collectedAt,
        ),
      );
    }
    return result;
  }
}

/// CVM — Dados abertos (`FONTES_DE_DADOS.md` §2.4): informe mensal de FIIs
/// e cotas diárias de fundos. Os ZIPs são lidos em memória (poucos MB) e não
/// ficam no disco.
class CvmProvider implements FundReportProvider {
  CvmProvider(this._http, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final MarketHttp _http;
  final Clock _clock;

  @override
  String get code => ProviderCatalog.cvm.code;

  @override
  Future<List<FundReport>> fiiMonthly(
    Set<String> isins, {
    required int year,
  }) async {
    final zip = await _zip(
      Uri.https(
        'dados.cvm.gov.br',
        '/dados/FII/DOC/INF_MENSAL/DADOS/inf_mensal_fii_$year.zip',
      ),
    );
    String? find(String prefix) {
      for (final f in zip.files) {
        if (f.isFile && p.basename(f.name).startsWith(prefix)) {
          return const Latin1Codec(allowInvalid: true).decode(f.content);
        }
      }
      return null;
    }

    final general = find('inf_mensal_fii_geral');
    final complement = find('inf_mensal_fii_complemento');
    if (general == null || complement == null) {
      MarketParse.invalid('CVM', 'arquivos do informe ausentes');
    }
    return parseFiiMonthly(
      general,
      complement,
      isins,
      collectedAt: formatInstant(_clock.now()),
    );
  }

  @override
  Future<List<FundReport>> dailyQuotas(
    Set<String> cnpjs, {
    required LocalDate month,
  }) async {
    final ym = '${month.year}${month.month.toString().padLeft(2, '0')}';
    final zip = await _zip(
      Uri.https(
        'dados.cvm.gov.br',
        '/dados/FI/DOC/INF_DIARIO/DADOS/inf_diario_fi_$ym.zip',
      ),
    );
    final file = zip.files.where((f) => f.isFile).firstOrNull;
    if (file == null) MarketParse.invalid('CVM', 'ZIP vazio');
    return parseDaily(
      const Latin1Codec(allowInvalid: true).decode(file.content),
      cnpjs,
      collectedAt: formatInstant(_clock.now()),
    );
  }

  Future<Archive> _zip(Uri uri) async {
    final List<int> bytes;
    try {
      bytes = await _http.getBytes(code, uri);
    } on HttpStatusError catch (e) {
      throw DataError(
        e.statusCode == 404
            ? 'A CVM ainda não publicou este arquivo.'
            : 'A CVM recusou o download (${e.statusCode}).',
      );
    }
    try {
      return ZipDecoder().decodeBytes(bytes);
    } on Object {
      MarketParse.invalid('CVM', 'ZIP ilegível');
    }
  }

  /// Informe mensal: o arquivo "geral" liga ISIN a CNPJ; o "complemento"
  /// traz patrimônio, cotistas e valor patrimonial por cota. Vale a maior
  /// `Versao` de cada mês (reenvios).
  static List<FundReport> parseFiiMonthly(
    String general,
    String complement,
    Set<String> isins, {
    required String collectedAt,
  }) {
    final generalRows = _csv(general);
    final cnpjByIsin = <String, String>{};
    final nameByCnpj = <String, String>{};
    for (final r in generalRows) {
      final isin = r['Codigo_ISIN']?.trim() ?? '';
      final cnpj = r['CNPJ_Fundo_Classe']?.trim() ?? '';
      if (isins.contains(isin) && cnpj.isNotEmpty) {
        cnpjByIsin[isin] = cnpj;
        nameByCnpj[cnpj] = r['Nome_Fundo_Classe']?.trim() ?? '';
      }
    }
    final isinByCnpj = {for (final e in cnpjByIsin.entries) e.value: e.key};
    final best = <(String, LocalDate), (int, Map<String, String>)>{};
    for (final r in _csv(complement)) {
      final cnpj = r['CNPJ_Fundo_Classe']?.trim() ?? '';
      if (!isinByCnpj.containsKey(cnpj)) continue;
      final date = MarketParse.isoDate(r['Data_Referencia']);
      if (date == null) continue;
      final version = int.tryParse(r['Versao'] ?? '') ?? 0;
      final current = best[(cnpj, date)];
      if (current == null || version > current.$1) {
        best[(cnpj, date)] = (version, r);
      }
    }
    final keys = best.keys.toList()..sort((a, b) => a.$2.compareTo(b.$2));
    return [
      for (final key in keys)
        FundReport(
          cnpj: key.$1,
          refDate: key.$2,
          kind: FundReportKind.fiiMonthly,
          quota: MarketParse.decimal(best[key]!.$2['Valor_Patrimonial_Cotas']),
          nav: MarketParse.decimal(best[key]!.$2['Patrimonio_Liquido']),
          holders: int.tryParse(best[key]!.$2['Total_Numero_Cotistas'] ?? ''),
          isin: isinByCnpj[key.$1],
          name: nameByCnpj[key.$1],
          source: ProviderCatalog.cvm.code,
          collectedAt: collectedAt,
        ),
    ];
  }

  /// Cotas diárias: `CNPJ_FUNDO_CLASSE;DT_COMPTC;VL_QUOTA;VL_PATRIM_LIQ;
  /// NR_COTST` (entre outras colunas).
  static List<FundReport> parseDaily(
    String text,
    Set<String> cnpjs, {
    required String collectedAt,
  }) => [
    for (final r in _csv(text))
      if (cnpjs.contains(
        (r['CNPJ_FUNDO_CLASSE'] ?? r['CNPJ_FUNDO'] ?? '').trim(),
      ))
        if (MarketParse.isoDate(r['DT_COMPTC']) case final date?)
          FundReport(
            cnpj: (r['CNPJ_FUNDO_CLASSE'] ?? r['CNPJ_FUNDO'])!.trim(),
            refDate: date,
            kind: FundReportKind.daily,
            quota: MarketParse.decimal(r['VL_QUOTA']),
            nav: MarketParse.decimal(r['VL_PATRIM_LIQ']),
            holders: int.tryParse(r['NR_COTST'] ?? ''),
            source: ProviderCatalog.cvm.code,
            collectedAt: collectedAt,
          ),
  ];

  /// CSV com `;` e cabeçalho na primeira linha.
  static List<Map<String, String>> _csv(String text) {
    final lines = const LineSplitter().convert(text);
    if (lines.isEmpty) return const [];
    final header = lines.first.split(';');
    return [
      for (final line in lines.skip(1))
        if (line.isNotEmpty)
          () {
            final cells = line.split(';');
            return {
              for (var i = 0; i < header.length && i < cells.length; i++)
                header[i]: cells[i],
            };
          }(),
    ];
  }
}
