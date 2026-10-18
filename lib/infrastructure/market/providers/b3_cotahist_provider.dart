import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:clock/clock.dart';
import 'package:decimal/decimal.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../../application/market/market_ports.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/time/instant_format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/finance/business_calendar.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/provider_catalog.dart';
import '../market_http.dart';

final _log = Logger('mercado');

/// Linha de cotação do COTAHIST já separada (tipo de registro `01`).
class CotahistRecord {
  const CotahistRecord({
    required this.date,
    required this.symbol,
    required this.marketType,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.quoteFactor,
    required this.isin,
  });

  final LocalDate date;
  final String symbol;

  /// `TPMERC`: `010` = à vista.
  final String marketType;
  final Decimal open;
  final Decimal high;
  final Decimal low;
  final Decimal close;

  /// Volume financeiro (R$).
  final Decimal volume;

  /// Preço por lote de N ações (`FATCOT`).
  final int quoteFactor;
  final String isin;
}

/// Resultado de uma extração: barras e ISINs por ticker.
class CotahistExtract {
  const CotahistExtract({required this.bars, required this.isins});

  final Map<String, List<PriceBar>> bars;
  final Map<String, String> isins;
}

/// B3 — Séries históricas (COTAHIST): preço oficial, sem ajuste
/// (`FONTES_DE_DADOS.md` §2.5, DECISIONS D-05 e D-35).
///
/// - Baixa só os arquivos necessários: o anual de cada ano do período ou,
///   para os últimos [dailyWindowDays] dias, os arquivos diários (pequenos).
/// - Extrai em fluxo, num isolate, só os tickers pedidos (mercado à vista).
/// - Apaga o ZIP e o TXT assim que termina, inclusive em falha (D-05).
class B3CotahistProvider implements HistoryProvider {
  B3CotahistProvider(
    this._http, {
    required this.cacheDir,
    Clock wallClock = const Clock(),
    BusinessCalendar? calendar,
  }) : _clock = wallClock,
       _calendar = calendar ?? BusinessCalendar.brazil;

  final MarketHttp _http;
  final String cacheDir;
  final Clock _clock;
  final BusinessCalendar _calendar;

  /// Até quantos dias atrás o app usa os arquivos diários em vez do anual.
  static const dailyWindowDays = 20;

  static const _classes = {'stock_br', 'fii', 'etf_br', 'bdr'};

  static String get folderName => 'cotahist';

  @override
  String get code => ProviderCatalog.b3Cotahist.code;

  @override
  bool supports(MarketInstrument i) =>
      i.market == 'B3' && _classes.contains(i.assetClass);

  @override
  Future<List<PriceBar>> history(
    MarketInstrument instrument, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final result = await historyFor({instrument.symbol}, from: from, to: to);
    return result.bars[instrument.symbol.toUpperCase()] ?? const [];
  }

  /// Histórico de vários tickers de uma vez (um download serve a todos).
  Future<CotahistExtract> historyFor(
    Set<String> symbols, {
    required LocalDate from,
    required LocalDate to,
    void Function(String step)? onStep,
  }) async {
    final wanted = {for (final s in symbols) s.toUpperCase()};
    final today = LocalDate.fromDateTime(_clock.now().toLocal());
    final last = to.isAfter(today) ? today : to;
    final bars = <String, List<PriceBar>>{};
    final isins = <String, String>{};
    final dailyFrom = today.addDays(-dailyWindowDays);

    final files = <(Uri, String)>[];
    if (!from.isBefore(dailyFrom)) {
      for (var d = from; !d.isAfter(last); d = d.addDays(1)) {
        if (!_calendar.isBusinessDay(d)) continue;
        final name = 'COTAHIST_D${_two(d.day)}${_two(d.month)}${d.year}.ZIP';
        files.add((_uriOf(name), name));
      }
    } else {
      for (var year = from.year; year <= last.year; year++) {
        final name = 'COTAHIST_A$year.ZIP';
        files.add((_uriOf(name), name));
      }
    }

    final dir = Directory(p.join(cacheDir, folderName))
      ..createSync(recursive: true);
    for (final (uri, name) in files) {
      final zip = p.join(dir.path, name);
      onStep?.call(name);
      try {
        try {
          await _http.download(code, uri, zip);
        } on HttpStatusError catch (e) {
          // Arquivo diário ainda não publicado (ou feriado não previsto).
          if (e.statusCode == 404 && name.contains('_D')) {
            _log.info('COTAHIST: $name ainda não publicado');
            continue;
          }
          throw DataError(
            'A B3 não forneceu o arquivo $name (${e.statusCode}).',
          );
        }
        final extract = await extractFile(
          zip,
          wanted,
          from: from,
          to: last,
          collectedAt: formatInstant(_clock.now()),
        );
        for (final MapEntry(:key, :value) in extract.bars.entries) {
          (bars[key] ??= []).addAll(value);
        }
        isins.addAll(extract.isins);
      } finally {
        deleteRaw(zip);
      }
    }
    for (final list in bars.values) {
      list.sort((a, b) => a.refDate.compareTo(b.refDate));
    }
    return CotahistExtract(bars: bars, isins: isins);
  }

  static Uri _uriOf(String name) =>
      Uri.https('bvmf.bmfbovespa.com.br', '/InstDados/SerHist/$name');

  /// Apaga o ZIP e o TXT extraído de [zipPath] (D-05).
  static void deleteRaw(String zipPath) {
    for (final path in [zipPath, _txtPathOf(zipPath)]) {
      try {
        final f = File(path);
        if (f.existsSync()) f.deleteSync();
      } on FileSystemException catch (e) {
        _log.warning('Não consegui apagar um arquivo do COTAHIST', e);
      }
    }
  }

  /// Apaga sobras de execuções interrompidas.
  static void cleanCache(String cacheDir) {
    final dir = Directory(p.join(cacheDir, folderName));
    if (!dir.existsSync()) return;
    for (final f in dir.listSync().whereType<File>()) {
      try {
        f.deleteSync();
      } on FileSystemException {
        // Em uso por outra instância; fica para a próxima.
      }
    }
  }

  static String _txtPathOf(String zipPath) => '$zipPath.txt';

  /// Descompacta [zipPath] e separa os tickers de [symbols], num isolate.
  static Future<CotahistExtract> extractFile(
    String zipPath,
    Set<String> symbols, {
    required LocalDate from,
    required LocalDate to,
    required String collectedAt,
  }) {
    final txt = _txtPathOf(zipPath);
    final fromText = '$from';
    final toText = '$to';
    return Isolate.run(() async {
      _unzipSingle(zipPath, txt);
      final bars = <String, List<PriceBar>>{};
      final isins = <String, String>{};
      final lines = File(txt)
          .openRead()
          .transform(latin1.decoder)
          .transform(const LineSplitter());
      final lo = LocalDate.parse(fromText);
      final hi = LocalDate.parse(toText);
      await for (final line in lines) {
        final r = parseLine(line, symbols);
        if (r == null || r.marketType != '010') continue;
        isins[r.symbol] = r.isin;
        if (r.date.isBefore(lo) || r.date.isAfter(hi)) continue;
        (bars[r.symbol] ??= []).add(toBar(r, collectedAt));
      }
      return CotahistExtract(bars: bars, isins: isins);
    });
  }

  static void _unzipSingle(String zipPath, String target) {
    final input = InputFileStream(zipPath);
    try {
      final archive = ZipDecoder().decodeStream(input);
      final entry = archive.files.where((f) => f.isFile).firstOrNull;
      if (entry == null) throw const FormatException('ZIP vazio');
      final output = OutputFileStream(target);
      try {
        entry.writeContent(output);
      } finally {
        output.closeSync();
      }
    } finally {
      input.closeSync();
    }
  }

  static PriceBar toBar(CotahistRecord r, String collectedAt) => PriceBar(
    symbol: r.symbol,
    market: 'B3',
    refDate: r.date,
    open: r.open,
    high: r.high,
    low: r.low,
    close: r.close,
    volume: r.volume,
    currency: 'BRL',
    quoteFactor: Decimal.fromInt(r.quoteFactor),
    source: ProviderCatalog.b3Cotahist.code,
    dataType: MarketDataType.close,
    collectedAt: collectedAt,
  );

  /// Lê uma linha do layout oficial (245 colunas). Devolve `null` para
  /// outros registros ou tickers fora de [symbols] (vazio = todos).
  static CotahistRecord? parseLine(String line, Set<String> symbols) {
    if (line.length < 245 || !line.startsWith('01')) return null;
    final symbol = line.substring(12, 24).trim();
    if (symbols.isNotEmpty && !symbols.contains(symbol)) return null;
    try {
      return CotahistRecord(
        date: LocalDate(
          int.parse(line.substring(2, 6)),
          int.parse(line.substring(6, 8)),
          int.parse(line.substring(8, 10)),
        ),
        symbol: symbol,
        marketType: line.substring(24, 27),
        open: _money(line.substring(56, 69)),
        high: _money(line.substring(69, 82)),
        low: _money(line.substring(82, 95)),
        close: _money(line.substring(108, 121)),
        volume: _money(line.substring(170, 188)),
        quoteFactor: int.parse(line.substring(210, 217)),
        isin: line.substring(230, 242).trim(),
      );
    } on FormatException {
      return null;
    }
  }

  /// Número com 2 casas implícitas ("0000000005968" = 59,68).
  static Decimal _money(String digits) {
    final n = int.parse(digits);
    return Decimal.parse('${n ~/ 100}.${(n % 100).toString().padLeft(2, '0')}');
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}
