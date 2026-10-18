import 'package:clock/clock.dart';

import '../../../application/market/market_ports.dart';
import '../../../core/time/instant_format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/provider_catalog.dart';
import '../market_http.dart';
import 'parse.dart';

/// Banco Central — SGS: CDI, Selic, meta Selic, IPCA e IGP-M
/// (`FONTES_DE_DADOS.md` §2.1).
///
/// Séries diárias aceitam no máximo 10 anos por consulta (desde 2025); o
/// adaptador pede em janelas de 5 anos.
class BcbSgsProvider implements IndicatorProvider {
  BcbSgsProvider(this._http, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final MarketHttp _http;
  final Clock _clock;

  static const _codes = {
    IndicatorSeries.cdi: 12,
    IndicatorSeries.selic: 11,
    IndicatorSeries.selicTarget: 432,
    IndicatorSeries.ipca: 433,
    IndicatorSeries.igpm: 189,
  };

  static const windowYears = 5;

  @override
  String get code => ProviderCatalog.bcbSgs.code;

  @override
  bool supports(IndicatorSeries series) => _codes.containsKey(series);

  @override
  Future<List<IndicatorPoint>> indicator(
    IndicatorSeries series, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final number = _codes[series]!;
    final result = <IndicatorPoint>[];
    var start = from;
    while (!start.isAfter(to)) {
      var end = LocalDate(
        start.year + windowYears,
        start.month,
        start.day,
      ).addDays(-1);
      if (end.isAfter(to)) end = to;
      final uri = Uri.https(
        'api.bcb.gov.br',
        '/dados/serie/bcdata.sgs.$number/dados',
        {
          'formato': 'json',
          'dataInicial': MarketParse.brFormat(start),
          'dataFinal': MarketParse.brFormat(end),
        },
      );
      final text = await _http.getText(code, uri);
      result.addAll(
        parse(text, series, collectedAt: formatInstant(_clock.now())),
      );
      start = end.addDays(1);
    }
    return result;
  }

  /// `[{"data":"01/10/2026","valor":"0.055131"}, ...]`. O SGS responde
  /// `{"erro": ...}` ou uma página HTML quando não tem dados ou recusa.
  static List<IndicatorPoint> parse(
    String text,
    IndicatorSeries series, {
    required String collectedAt,
  }) {
    final trimmed = text.trimLeft();
    if (trimmed.startsWith('<')) {
      MarketParse.invalid('Banco Central (SGS)', 'página HTML');
    }
    final json = MarketParse.json('Banco Central (SGS)', text);
    if (json is Map<String, Object?>) {
      // Sem dados no período ("Value(s) not found") ou erro do serviço.
      final error = json['erro'] ?? json['error'];
      if (error != null && '$error'.contains('not found')) return const [];
      MarketParse.invalid('Banco Central (SGS)', 'erro do serviço');
    }
    final rows = MarketParse.list('Banco Central (SGS)', json, 'resposta');
    return [
      for (final r in rows)
        if (r is Map<String, Object?>)
          if (MarketParse.brDate(r['data']) case final date?)
            if (MarketParse.decimal(r['valor']) case final value?)
              IndicatorPoint(
                series: series,
                refDate: date,
                value: value,
                source: ProviderCatalog.bcbSgs.code,
                collectedAt: collectedAt,
              ),
    ];
  }
}

/// Banco Central — PTAX: câmbio oficial (`FONTES_DE_DADOS.md` §2.2). Guarda
/// só o boletim de fechamento de cada dia.
class BcbPtaxProvider implements FxProvider {
  BcbPtaxProvider(this._http, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final MarketHttp _http;
  final Clock _clock;

  /// Moedas com PTAX publicada pelo Banco Central (as mais comuns).
  static const currencies = {
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'DKK',
    'NOK',
    'SEK',
  };

  @override
  String get code => ProviderCatalog.bcbPtax.code;

  @override
  bool supports(String currency) => currencies.contains(currency);

  @override
  Future<List<FxRate>> rates(
    String currency, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final base =
        'https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/'
        'odata/';
    final params =
        "@dataInicial='${MarketParse.usFormat(from)}'"
        "&@dataFinalCotacao='${MarketParse.usFormat(to)}'"
        r'&$format=json';
    final url = currency == 'USD'
        ? '${base}CotacaoDolarPeriodo(dataInicial=@dataInicial,'
              'dataFinalCotacao=@dataFinalCotacao)?$params'
        : '${base}CotacaoMoedaPeriodo(moeda=@moeda,dataInicial=@dataInicial,'
              "dataFinalCotacao=@dataFinalCotacao)?@moeda='$currency'&$params";
    final text = await _http.getText(code, Uri.parse(url));
    return parse(text, currency, collectedAt: formatInstant(_clock.now()));
  }

  /// `{"value":[{"cotacaoCompra":5.0090,"cotacaoVenda":5.0096,
  /// "dataHoraCotacao":"2026-10-13 13:04:26.866","tipoBoletim":"Fechamento"}]}`.
  /// O dólar não traz `tipoBoletim`: vale a última cotação do dia.
  static List<FxRate> parse(
    String text,
    String currency, {
    required String collectedAt,
  }) {
    const name = 'Banco Central (PTAX)';
    final json = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final rows = MarketParse.list(name, json['value'], 'value');
    final byDay = <LocalDate, Map<String, Object?>>{};
    for (final r in rows) {
      if (r is! Map<String, Object?>) continue;
      final kind = r['tipoBoletim'];
      if (kind != null && kind != 'Fechamento') continue;
      final at = '${r['dataHoraCotacao']}';
      final day = MarketParse.isoDate(at);
      if (day == null) continue;
      final current = byDay[day];
      if (current == null ||
          '${current['dataHoraCotacao']}'.compareTo(at) < 0) {
        byDay[day] = r;
      }
    }
    final days = byDay.keys.toList()..sort();
    return [
      for (final day in days)
        FxRate(
          base: currency,
          quote: 'BRL',
          refDate: day,
          kind: FxKind.ptaxClose,
          bid: MarketParse.decimal(byDay[day]!['cotacaoCompra']),
          ask: MarketParse.decimal(byDay[day]!['cotacaoVenda']),
          refAt: _brasilia('${byDay[day]!['dataHoraCotacao']}'),
          source: ProviderCatalog.bcbPtax.code,
          collectedAt: collectedAt,
        ),
    ];
  }

  /// "2026-10-13 13:04:26.866133" em Brasília (UTC−3) → UTC.
  static DateTime? _brasilia(String text) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})')
        .firstMatch(text);
    if (m == null) return null;
    int g(int i) => int.parse(m.group(i)!);
    return DateTime.utc(g(1), g(2), g(3), g(4) + 3, g(5), g(6));
  }
}

/// IBGE — SIDRA: IPCA (tabela 1737, variável 63), alternativa ao SGS.
class IbgeSidraProvider implements IndicatorProvider {
  IbgeSidraProvider(this._http, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final MarketHttp _http;
  final Clock _clock;

  @override
  String get code => ProviderCatalog.ibgeSidra.code;

  @override
  bool supports(IndicatorSeries series) => series == IndicatorSeries.ipca;

  @override
  Future<List<IndicatorPoint>> indicator(
    IndicatorSeries series, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    String period(LocalDate d) =>
        '${d.year}${d.month.toString().padLeft(2, '0')}';
    final uri = Uri.parse(
      'https://apisidra.ibge.gov.br/values/t/1737/n1/all/v/63/p/'
      '${period(from)}-${period(to)}',
    );
    final text = await _http.getText(code, uri);
    return parse(text, collectedAt: formatInstant(_clock.now()));
  }

  /// Lista em que a primeira linha é o cabeçalho; `V` é o valor e `D3C` o
  /// mês (`202609`). Valores ausentes vêm como "..." ou "-".
  static List<IndicatorPoint> parse(
    String text, {
    required String collectedAt,
  }) {
    const name = 'IBGE (SIDRA)';
    final rows = MarketParse.list(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final result = <IndicatorPoint>[];
    for (final r in rows.skip(1)) {
      if (r is! Map<String, Object?>) continue;
      final month = '${r['D3C']}';
      final value = MarketParse.decimal(r['V']);
      if (value == null || !RegExp(r'^\d{6}$').hasMatch(month)) continue;
      result.add(
        IndicatorPoint(
          series: IndicatorSeries.ipca,
          refDate: LocalDate(
            int.parse(month.substring(0, 4)),
            int.parse(month.substring(4)),
            1,
          ),
          value: value,
          source: ProviderCatalog.ibgeSidra.code,
          collectedAt: collectedAt,
        ),
      );
    }
    return result;
  }
}

/// Frankfurter: taxas de referência do BCE, para moedas sem PTAX ou quando a
/// PTAX falha (`FONTES_DE_DADOS.md` §2.13).
class FrankfurterProvider implements FxProvider {
  FrankfurterProvider(this._http, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final MarketHttp _http;
  final Clock _clock;

  @override
  String get code => ProviderCatalog.frankfurter.code;

  @override
  bool supports(String currency) => currency.length == 3 && currency != 'BRL';

  @override
  Future<List<FxRate>> rates(
    String currency, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final uri = Uri.https('api.frankfurter.dev', '/v1/$from..$to', {
      'from': currency,
      'to': 'BRL',
    });
    final text = await _http.getText(code, uri);
    return parse(text, currency, collectedAt: formatInstant(_clock.now()));
  }

  /// `{"base":"EUR","rates":{"2026-10-01":{"BRL":5.862}}}`.
  static List<FxRate> parse(
    String text,
    String currency, {
    required String collectedAt,
  }) {
    const name = 'Frankfurter';
    final json = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final rates = MarketParse.map(name, json['rates'], 'rates');
    final result = <FxRate>[];
    for (final MapEntry(:key, :value) in rates.entries) {
      final day = MarketParse.isoDate(key);
      final brl = value is Map<String, Object?>
          ? MarketParse.decimal(value['BRL'])
          : null;
      if (day == null || brl == null) continue;
      result.add(
        FxRate(
          base: currency,
          quote: 'BRL',
          refDate: day,
          kind: FxKind.reference,
          bid: brl,
          ask: brl,
          source: ProviderCatalog.frankfurter.code,
          collectedAt: collectedAt,
        ),
      );
    }
    result.sort((a, b) => a.refDate.compareTo(b.refDate));
    return result;
  }
}
