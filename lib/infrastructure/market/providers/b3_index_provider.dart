import 'dart:convert';

import 'package:clock/clock.dart';

import '../../../application/market/market_ports.dart';
import '../../../core/time/instant_format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/provider_catalog.dart';
import '../market_http.dart';
import 'parse.dart';

/// B3 — estatísticas de índices: fechamento diário do Ibovespa, um ano por
/// requisição (`FONTES_DE_DADOS.md` §2.5d; DECISIONS D-50). Endereço
/// interno do site da B3, o mesmo serviço dos proventos.
///
/// A resposta é uma tabela com uma linha por dia do mês (`day`) e uma
/// coluna por mês (`rateValue1` a `rateValue12`), em pontos no formato
/// brasileiro ("126.601,55"); dias sem pregão vêm nulos.
class B3IndexProvider implements IndicatorProvider {
  B3IndexProvider(this._http, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final MarketHttp _http;
  final Clock _clock;

  static const _host = 'sistemaswebb3-listados.b3.com.br';
  static const _codes = {IndicatorSeries.ibovespa: 'IBOV'};

  @override
  String get code => ProviderCatalog.b3Indices.code;

  @override
  bool supports(IndicatorSeries series) => _codes.containsKey(series);

  @override
  Future<List<IndicatorPoint>> indicator(
    IndicatorSeries series, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final index = _codes[series]!;
    final collectedAt = formatInstant(_clock.now());
    final result = <IndicatorPoint>[];
    for (var year = from.year; year <= to.year; year++) {
      final param = base64.encode(
        utf8.encode(
          jsonEncode({'index': index, 'language': 'pt-br', 'year': '$year'}),
        ),
      );
      final text = await _http.getText(
        code,
        Uri.https(
          _host,
          '/indexStatisticsProxy/IndexCall/GetPortfolioDay/$param',
        ),
      );
      for (final p in parse(
        text,
        series: series,
        year: year,
        collectedAt: collectedAt,
      )) {
        if (!p.refDate.isBefore(from) && !p.refDate.isAfter(to)) result.add(p);
      }
    }
    return result;
  }

  static List<IndicatorPoint> parse(
    String text, {
    required IndicatorSeries series,
    required int year,
    required String collectedAt,
  }) {
    const name = 'B3 (índices)';
    final json = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final rows = MarketParse.list(name, json['results'], 'results');
    final result = <IndicatorPoint>[];
    for (final row in rows) {
      if (row is! Map<String, Object?>) continue;
      final day = MarketParse.decimal(row['day'])?.toBigInt().toInt();
      if (day == null || day < 1 || day > 31) continue;
      for (var month = 1; month <= 12; month++) {
        final value = MarketParse.decimal(
          row['rateValue$month'],
          brazilian: true,
        );
        if (value == null) continue;
        // Dias que não existem no mês (31/02) nunca têm valor; por garantia.
        final date = LocalDate(year, month, day);
        if (date.month != month) continue;
        result.add(
          IndicatorPoint(
            series: series,
            refDate: date,
            value: value,
            source: ProviderCatalog.b3Indices.code,
            collectedAt: collectedAt,
          ),
        );
      }
    }
    result.sort((a, b) => a.refDate.compareTo(b.refDate));
    return result;
  }
}
