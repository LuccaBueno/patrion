import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';

/// Metodologia de um retorno. Ao mostrar ou comparar retornos, a interface
/// sempre informa qual foi usada (SPEC §9).
enum ReturnMethod {
  /// (valor final − custo) ÷ custo, sem considerar quando o dinheiro entrou.
  simple,

  /// Retornos de subperíodos encadeados: (1 + r₁)(1 + r₂)… − 1.
  accumulated,

  /// Taxa anual composta equivalente a um retorno do período (CAGR).
  cagr,

  /// Retorno ponderado pelo tempo: neutraliza aportes e retiradas; mede o
  /// desempenho dos ativos.
  twr,

  /// Retorno ponderado pelo dinheiro (TIR/XIRR): considera o tamanho e a
  /// data de cada aporte; mede a experiência do investidor.
  mwr,
}

/// Um retorno com a metodologia e o período (`docs/FORMULAS.md` §8).
class ReturnFigure {
  const ReturnFigure({
    required this.value,
    required this.method,
    required this.start,
    required this.end,
    required this.annualized,
  });

  /// Fração (0,1 = 10%).
  final Decimal value;
  final ReturnMethod method;
  final LocalDate start;
  final LocalDate end;

  /// `true`: taxa ao ano; `false`: retorno acumulado no período.
  final bool annualized;

  int get days => end.daysSince(start);
}

/// Funções de retorno (SPEC §9). Todas devolvem frações e usam
/// [DecimalMath] (20 casas, meio para o par).
abstract final class Returns {
  /// Retorno simples: `final ÷ inicial − 1`. Nulo se [start] ≤ 0.
  static Decimal? simple(Decimal start, Decimal end) => start <= Decimal.zero
      ? null
      : DecimalMath.divide(end, start) - Decimal.one;

  /// Encadeia retornos de subperíodos: `Π(1 + rᵢ) − 1`.
  static Decimal accumulate(Iterable<Decimal> returns) {
    var factor = Decimal.one;
    for (final r in returns) {
      factor = DecimalMath.rescale(factor * (Decimal.one + r));
    }
    return factor - Decimal.one;
  }

  /// Anualiza um retorno do período: `(1 + r)^(base ÷ dias) − 1`.
  ///
  /// [yearDays] é 365 para dias corridos (padrão, mesma convenção do XIRR)
  /// ou 252 para dias úteis. Nulo se [days] ≤ 0 ou se o retorno for ≤ −100%.
  static Decimal? annualize(
    Decimal periodReturn,
    int days, {
    int yearDays = 365,
  }) {
    if (days <= 0 || periodReturn <= -Decimal.one) return null;
    final exponent = DecimalMath.divide(
      Decimal.fromInt(yearDays),
      Decimal.fromInt(days),
    );
    return DecimalMath.pow(Decimal.one + periodReturn, exponent) - Decimal.one;
  }

  /// Converte uma taxa anual para o período: `(1 + a)^(dias ÷ base) − 1`.
  static Decimal deannualize(
    Decimal annualRate,
    int days, {
    int yearDays = 365,
  }) {
    final exponent = DecimalMath.divide(
      Decimal.fromInt(days),
      Decimal.fromInt(yearDays),
    );
    return DecimalMath.pow(Decimal.one + annualRate, exponent) - Decimal.one;
  }

  /// CAGR entre dois valores: `(final ÷ inicial)^(365 ÷ dias) − 1`.
  static Decimal? cagr(
    Decimal start,
    Decimal end,
    LocalDate from,
    LocalDate to,
  ) {
    final r = simple(start, end);
    if (r == null) return null;
    return annualize(r, to.daysSince(from));
  }

  /// Retorno real (descontada a inflação): `(1 + nominal) ÷ (1 + inflação)
  /// − 1`.
  static Decimal real(Decimal nominal, Decimal inflation) =>
      DecimalMath.divide(Decimal.one + nominal, Decimal.one + inflation) -
      Decimal.one;
}

/// Retorno de um ativo em outra moeda, separado em efeito do ativo, efeito
/// cambial e efeito cruzado (`docs/FORMULAS.md` §9):
///
/// `(1 + r_BRL) = (1 + r_ativo) × (1 + r_câmbio)`, logo
/// `r_BRL = r_ativo + r_câmbio + r_ativo × r_câmbio`.
class FxDecomposition {
  const FxDecomposition({required this.assetReturn, required this.fxReturn});

  /// A partir de valores na moeda original e das cotações de câmbio (preço
  /// da moeda original em BRL) no início e no fim. Nulo se algum valor
  /// inicial for ≤ 0.
  static FxDecomposition? fromValues({
    required Decimal startValue,
    required Decimal endValue,
    required Decimal startFx,
    required Decimal endFx,
  }) {
    final asset = Returns.simple(startValue, endValue);
    final fx = Returns.simple(startFx, endFx);
    if (asset == null || fx == null) return null;
    return FxDecomposition(assetReturn: asset, fxReturn: fx);
  }

  /// Retorno na moeda original.
  final Decimal assetReturn;

  /// Variação da moeda original em BRL.
  final Decimal fxReturn;

  Decimal get crossEffect => assetReturn * fxReturn;

  /// Retorno em BRL.
  Decimal get totalReturn => assetReturn + fxReturn + crossEffect;
}

/// Valor da carteira numa data: antes do fluxo do dia e o fluxo externo do
/// dia (aporte positivo, retirada negativa).
class ValuationPoint {
  ValuationPoint(this.date, this.valueBeforeFlow, [Decimal? flow])
    : flow = flow ?? Decimal.zero;

  final LocalDate date;

  /// Valor de mercado no fim do dia, sem o fluxo do dia.
  final Decimal valueBeforeFlow;

  /// Aporte (+) ou retirada (−) no fim do dia.
  final Decimal flow;

  Decimal get valueAfterFlow => valueBeforeFlow + flow;
}

/// Retorno ponderado pelo tempo (TWR), `docs/FORMULAS.md` §8.3.
///
/// Os fluxos são considerados no fim do dia: o retorno de cada subperíodo é
/// `Vᵢ (antes do fluxo) ÷ Vᵢ₋₁ (depois do fluxo) − 1`, e o TWR é o produto
/// dos fatores menos 1. Subperíodos sem capital (valor anterior zero e valor
/// atual zero) são pulados. Um subperíodo que começa em zero e termina com
/// valor não tem retorno definido: o resultado é `null`.
abstract final class Twr {
  /// Índice acumulado em cada ponto, começando em 1 no primeiro.
  static List<(LocalDate, Decimal)>? index(List<ValuationPoint> points) {
    if (points.isEmpty) return const [];
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
    final result = <(LocalDate, Decimal)>[(sorted.first.date, Decimal.one)];
    var factor = Decimal.one;
    for (var i = 1; i < sorted.length; i++) {
      final previous = sorted[i - 1].valueAfterFlow;
      final current = sorted[i].valueBeforeFlow;
      if (previous == Decimal.zero) {
        if (current != Decimal.zero) return null;
      } else {
        factor = DecimalMath.rescale(
          factor * DecimalMath.divide(current, previous),
        );
      }
      result.add((sorted[i].date, factor));
    }
    return result;
  }

  /// TWR do período inteiro (não anualizado).
  static Decimal? compute(List<ValuationPoint> points) {
    final idx = index(points);
    if (idx == null || idx.isEmpty) return null;
    return idx.last.$2 - Decimal.one;
  }
}

/// Granularidade dos retornos por período.
enum ReturnPeriodUnit { day, month, year }

/// Retorno de um período do calendário.
class PeriodReturn {
  const PeriodReturn(this.start, this.end, this.value);

  /// Primeiro dia do período (o dia, o dia 1 do mês ou 1/1).
  final LocalDate start;

  /// Último ponto com valor dentro do período.
  final LocalDate end;

  /// Fração (0,01 = 1%).
  final Decimal value;
}

/// Retornos diários, mensais e anuais a partir do índice do TWR
/// (`docs/FORMULAS.md` §8.4).
///
/// O retorno de um período é `índice no último ponto do período ÷ índice no
/// último ponto antes dele − 1`. O primeiro período começa no primeiro
/// ponto; se ele não estiver no início do período, o retorno é parcial (a
/// partir do primeiro ponto).
abstract final class PeriodReturns {
  static List<PeriodReturn> compute(
    List<(LocalDate, Decimal)> index,
    ReturnPeriodUnit unit,
  ) {
    if (index.length < 2) return const [];
    LocalDate keyOf(LocalDate d) => switch (unit) {
      ReturnPeriodUnit.day => d,
      ReturnPeriodUnit.month => LocalDate(d.year, d.month, 1),
      ReturnPeriodUnit.year => LocalDate(d.year, 1, 1),
    };

    final result = <PeriodReturn>[];
    var baseValue = index.first.$2;
    var currentKey = keyOf(index.first.$1);
    var lastDate = index.first.$1;
    var lastValue = index.first.$2;
    var hasPoints = false;
    for (var i = 1; i < index.length; i++) {
      final (date, value) = index[i];
      final key = keyOf(date);
      if (key != currentKey) {
        if (hasPoints) {
          result.add(
            PeriodReturn(
              currentKey,
              lastDate,
              DecimalMath.divide(lastValue, baseValue) - Decimal.one,
            ),
          );
        }
        baseValue = lastValue;
        currentKey = key;
      }
      lastDate = date;
      lastValue = value;
      hasPoints = true;
    }
    result.add(
      PeriodReturn(
        currentKey,
        lastDate,
        DecimalMath.divide(lastValue, baseValue) - Decimal.one,
      ),
    );
    return result;
  }
}
