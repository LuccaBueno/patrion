import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';

/// Fluxo de caixa do ponto de vista do investidor: negativo quando o dinheiro
/// sai do bolso (compra, aporte), positivo quando volta (venda, provento,
/// valor final da carteira).
class CashFlow {
  const CashFlow(this.date, this.amount);

  final LocalDate date;
  final Decimal amount;

  @override
  String toString() => 'CashFlow($date, $amount)';
}

/// Resultado do XIRR.
class XirrResult {
  const XirrResult({required this.rate, required this.multipleSignChanges});

  /// Taxa anual efetiva (0,1 = 10% a.a.), convenção dias corridos ÷ 365.
  final Decimal rate;

  /// Os fluxos mudam de sinal mais de uma vez: pode haver mais de uma taxa
  /// que zera o valor presente. A escolhida é a mais próxima de 10% a.a.
  final bool multipleSignChanges;
}

/// Taxa interna de retorno com datas irregulares (XIRR), igual à do Excel
/// (`docs/FORMULAS.md` §7):
///
/// `Σ Fᵢ ÷ (1 + r)^((dᵢ − d₀) ÷ 365) = 0`
///
/// Resolvida por Newton protegido por bisseção dentro de um intervalo onde o
/// valor presente troca de sinal. Sem solução (todos os fluxos com o mesmo
/// sinal, ou nenhuma troca de sinal no intervalo pesquisado), devolve `null`:
/// a interface mostra "indisponível".
abstract final class Xirr {
  /// Precisão da taxa: 12 casas (10⁻¹⁰ pontos percentuais).
  static final _tolerance = Decimal.parse('1e-12');
  static const _maxIterations = 200;
  static final _days = Decimal.fromInt(365);
  static final _two = Decimal.fromInt(2);

  /// Pontos onde o valor presente é avaliado para achar o intervalo.
  static final _grid = [
    '-0.99',
    '-0.9',
    '-0.7',
    '-0.5',
    '-0.3',
    '-0.2',
    '-0.1',
    '-0.05',
    '0',
    '0.05',
    '0.1',
    '0.2',
    '0.3',
    '0.5',
    '1',
    '2',
    '5',
    '10',
    '100',
    '1000',
  ].map(Decimal.parse).toList();

  static XirrResult? compute(Iterable<CashFlow> flows) {
    final list = flows.where((f) => f.amount != Decimal.zero).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (!list.any((f) => f.amount > Decimal.zero) ||
        !list.any((f) => f.amount < Decimal.zero)) {
      return null;
    }
    final start = list.first.date;
    final terms = [
      for (final f in list)
        (
          DecimalMath.divide(Decimal.fromInt(f.date.daysSince(start)), _days),
          f.amount,
        ),
    ];
    if (terms.every((t) => t.$1 == Decimal.zero)) return null;

    var signChanges = 0;
    for (var i = 1; i < list.length; i++) {
      if (list[i].amount.sign != list[i - 1].amount.sign) signChanges++;
    }

    // Intervalos com troca de sinal; o escolhido é o mais perto de 10%.
    final values = [for (final r in _grid) _npv(terms, r)];
    (Decimal, Decimal, Decimal, Decimal)? best;
    Decimal? bestDistance;
    for (var i = 1; i < _grid.length; i++) {
      final (a, b) = (values[i - 1], values[i]);
      if (a == Decimal.zero) return _result(_grid[i - 1], signChanges);
      if (a.sign == b.sign) continue;
      final mid = DecimalMath.divide(_grid[i - 1] + _grid[i], _two);
      final distance = (mid - Decimal.parse('0.1')).abs();
      if (bestDistance == null || distance < bestDistance) {
        best = (_grid[i - 1], _grid[i], a, b);
        bestDistance = distance;
      }
    }
    if (values.last == Decimal.zero) {
      return _result(_grid.last, signChanges);
    }
    if (best == null) return null;
    return _result(_solve(terms, best), signChanges);
  }

  static XirrResult _result(Decimal rate, int signChanges) =>
      XirrResult(rate: rate, multipleSignChanges: signChanges > 1);

  /// Newton dentro de [lo, hi]; se o passo sair do intervalo ou não reduzir
  /// o erro, faz bisseção.
  static Decimal _solve(
    List<(Decimal, Decimal)> terms,
    (Decimal, Decimal, Decimal, Decimal) bracket,
  ) {
    var (lo, hi, fLo, _) = bracket;
    var r = DecimalMath.divide(lo + hi, _two);
    for (var i = 0; i < _maxIterations; i++) {
      final (f, df) = _npvAndDerivative(terms, r);
      if (f == Decimal.zero) return r;
      if (f.sign == fLo.sign) {
        lo = r;
        fLo = f;
      } else {
        hi = r;
      }
      Decimal next;
      if (df != Decimal.zero) {
        next = r - DecimalMath.divide(f, df);
        if (next <= lo || next >= hi) {
          next = DecimalMath.divide(lo + hi, _two);
        }
      } else {
        next = DecimalMath.divide(lo + hi, _two);
      }
      final step = (next - r).abs();
      r = next;
      if (step < _tolerance || hi - lo < _tolerance) break;
    }
    return DecimalMath.rescale(r, scale: 16);
  }

  /// Valor presente com a taxa [r].
  static Decimal _npv(List<(Decimal, Decimal)> terms, Decimal r) =>
      _npvAndDerivative(terms, r, derivative: false).$1;

  /// Valor presente e sua derivada em relação a [r]:
  /// `f = Σ F (1+r)^−t` e `f' = Σ −t F (1+r)^(−t−1)`.
  static (Decimal, Decimal) _npvAndDerivative(
    List<(Decimal, Decimal)> terms,
    Decimal r, {
    bool derivative = true,
  }) {
    final base = Decimal.one + r;
    final lnBase = DecimalMath.ln(base, scale: 30);
    var f = Decimal.zero;
    var df = Decimal.zero;
    for (final (t, amount) in terms) {
      final discount = t == Decimal.zero
          ? Decimal.one
          : DecimalMath.exp(-(t * lnBase), scale: 30);
      final pv = amount * discount;
      f += pv;
      if (derivative && t != Decimal.zero) {
        df -= DecimalMath.divide(t * pv, base, scale: 30);
      }
    }
    return (
      DecimalMath.rescale(f, scale: 30),
      DecimalMath.rescale(df, scale: 30),
    );
  }
}
