import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import 'market_data.dart';
import 'market_price.dart';

/// Um ponto da série de preços de um ativo.
class PricePoint {
  const PricePoint(this.date, this.price);

  final LocalDate date;
  final Decimal price;

  @override
  String toString() => '$date $price';
}

/// Salto de preço entre dois pregões seguidos sem evento em ações que o
/// explique: pode ser um desdobramento ou grupamento que a fonte não
/// listou (`FONTES_DE_DADOS.md` §1). Nunca é corrigido automaticamente.
class PriceJump {
  const PriceJump(this.from, this.to);

  final PricePoint from;
  final PricePoint to;

  /// Variação do salto (fração).
  Decimal get change => DecimalMath.divide(to.price, from.price) - Decimal.one;
}

/// Variação, máxima e mínima de um trecho da série.
class PeriodSummary {
  const PeriodSummary({
    required this.first,
    required this.last,
    required this.high,
    required this.low,
  });

  final PricePoint first;
  final PricePoint last;
  final PricePoint high;
  final PricePoint low;

  /// `último ÷ primeiro − 1`.
  Decimal get change =>
      DecimalMath.divide(last.price, first.price) - Decimal.one;
}

/// Série de preços do gráfico do ativo (M-07; `docs/FORMULAS.md` §2.5):
/// fechamentos publicados e o preço ajustado por proventos e eventos,
/// calculado pelo app.
abstract final class PriceSeries {
  /// Proventos em dinheiro que ajustam o preço.
  static const cashKinds = {
    CorporateEventKind.cashDividend,
    CorporateEventKind.jcp,
    CorporateEventKind.fiiIncome,
    CorporateEventKind.amortization,
    CorporateEventKind.otherCash,
  };

  /// Saltos a partir deste tamanho (para cima ou para baixo) sem evento em
  /// ações são suspeitos: −40% ou +66,7% (o inverso de −40%).
  static final jumpDown = Decimal.parse('0.6');
  static final jumpUp = DecimalMath.divide(Decimal.one, jumpDown);

  /// Fechamentos unitários (preço por lote ÷ fator de cotação), um por
  /// data, em ordem.
  static List<PricePoint> closes(Iterable<PriceBar> bars) {
    final byDate = <LocalDate, PricePoint>{};
    for (final b in bars) {
      byDate[b.refDate] = PricePoint(b.refDate, MarketPricing.unitClose(b));
    }
    return byDate.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Preço ajustado para trás por proventos e eventos: cada preço anterior
  /// à data ex de um evento é multiplicado pelo fator do evento.
  ///
  /// - provento em dinheiro de valor `D`: `1 − D ÷ P`, com `P` o último
  ///   fechamento antes da data ex (a data com);
  /// - desdobramento, grupamento e bonificação de multiplicador `q` (2 num
  ///   1:2): `1 ÷ q`.
  ///
  /// Eventos suspeitos, sem valor ou fator, fora da série ou com `D ≥ P`
  /// ficam de fora. O último preço não muda.
  static List<PricePoint> adjusted(
    List<PricePoint> closes,
    Iterable<CorporateEvent> events,
  ) {
    if (closes.length < 2) return closes;
    // Fator acumulado a aplicar a todos os preços antes do índice.
    final factorBefore = <int, Decimal>{};
    for (final e in events) {
      if (e.status == CorporateEventStatus.suspect) continue;
      final i = _firstOnOrAfter(closes, e.exDate);
      if (i == null || i == 0) continue;
      final previous = closes[i - 1].price;
      Decimal? f;
      if (cashKinds.contains(e.kind)) {
        final amount = e.amount;
        if (amount == null || amount <= Decimal.zero || amount >= previous) {
          continue;
        }
        f = Decimal.one - DecimalMath.divide(amount, previous);
      } else if (e.kind.changesQuantity) {
        final q = e.factor;
        if (q == null || q <= Decimal.zero) continue;
        f = DecimalMath.divide(Decimal.one, q);
      }
      if (f == null) continue;
      factorBefore[i] = DecimalMath.rescale(
        (factorBefore[i] ?? Decimal.one) * f,
      );
    }
    if (factorBefore.isEmpty) return closes;
    final result = List<PricePoint>.filled(closes.length, closes.last);
    var cumulative = Decimal.one;
    for (var i = closes.length - 1; i >= 0; i--) {
      final c = closes[i];
      result[i] = PricePoint(c.date, DecimalMath.rescale(c.price * cumulative));
      final f = factorBefore[i];
      if (f != null) cumulative = DecimalMath.rescale(cumulative * f);
    }
    return result;
  }

  /// Saltos de pregão para pregão a partir de −40% ou +66,7% sem evento em
  /// ações (desdobramento, grupamento, bonificação) com data ex entre o dia
  /// seguinte ao primeiro pregão e três dias depois do segundo.
  static List<PriceJump> suspectJumps(
    List<PricePoint> closes,
    Iterable<CorporateEvent> events,
  ) {
    final quantityEvents = [
      for (final e in events)
        if (e.kind.changesQuantity && e.status != CorporateEventStatus.suspect)
          e.exDate,
    ];
    final result = <PriceJump>[];
    for (var i = 1; i < closes.length; i++) {
      final a = closes[i - 1];
      final b = closes[i];
      if (a.price <= Decimal.zero) continue;
      final ratio = DecimalMath.divide(b.price, a.price);
      if (ratio > jumpDown && ratio < jumpUp) continue;
      final explained = quantityEvents.any(
        (d) => d.isAfter(a.date) && !d.isAfter(b.date.addDays(3)),
      );
      if (!explained) result.add(PriceJump(a, b));
    }
    return result;
  }

  /// Pontos a partir de [from] (inclusive); nulo pega a série toda.
  static List<PricePoint> since(List<PricePoint> series, LocalDate? from) {
    if (from == null) return series;
    final i = _firstOnOrAfter(series, from);
    return i == null ? const [] : series.sublist(i);
  }

  /// Variação, máxima e mínima; nulo com menos de dois pontos.
  static PeriodSummary? summary(List<PricePoint> series) {
    if (series.length < 2) return null;
    var high = series.first;
    var low = series.first;
    for (final p in series) {
      if (p.price > high.price) high = p;
      if (p.price < low.price) low = p;
    }
    return PeriodSummary(
      first: series.first,
      last: series.last,
      high: high,
      low: low,
    );
  }

  static int? _firstOnOrAfter(List<PricePoint> series, LocalDate date) {
    var lo = 0;
    var hi = series.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (series[mid].date.isBefore(date)) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo < series.length ? lo : null;
  }
}
