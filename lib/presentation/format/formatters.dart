import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';

/// Formatação e leitura de números e datas em pt-BR, direto do `Decimal`
/// (sem passar por ponto flutuante, regra 6).
abstract final class Fmt {
  static const _symbols = {'BRL': r'R$', 'USD': r'US$', 'EUR': '€'};

  /// Valor em moeda com 2 casas, meio para cima (DECISIONS D-03):
  /// `R$ 1.234,56`, `-R$ 10,00`, `US$ 5,00`, `GBP 3,00`.
  static String money(Decimal value, String currency) {
    final symbol = _symbols[currency] ?? currency;
    final rounded = DecimalMath.roundHalfUp(value);
    final sign = rounded < Decimal.zero ? '-' : '';
    return '$sign$symbol ${_group(rounded.abs(), 2)}';
  }

  /// Valor com sinal explícito para ganhos e perdas: `+R$ 10,00`.
  static String signedMoney(Decimal value, String currency) {
    final text = money(value, currency);
    return DecimalMath.roundHalfUp(value) > Decimal.zero ? '+$text' : text;
  }

  /// Número com até [maxDecimals] casas, sem zeros à direita:
  /// `1.234,5`, `0,00012345`.
  static String number(Decimal value, {int maxDecimals = 8}) {
    final rounded = DecimalMath.roundHalfUp(value, scale: maxDecimals);
    final sign = rounded < Decimal.zero ? '-' : '';
    final abs = rounded.abs();
    return '$sign${_group(abs, abs.scale)}';
  }

  /// Fração como percentual com 2 casas e sinal: 0,1234 → `+12,34%`.
  static String percent(Decimal fraction, {bool signed = true}) {
    final pct = DecimalMath.roundHalfUp(fraction * Decimal.fromInt(100));
    final sign = pct < Decimal.zero
        ? '-'
        : (signed && pct > Decimal.zero ? '+' : '');
    return '$sign${_group(pct.abs(), 2)}%';
  }

  /// `17/10/2026`.
  static String date(LocalDate d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year.toString().padLeft(4, '0')}';

  /// `03/2019`.
  static String monthYear(LocalDate d) =>
      '${_two(d.month)}/${d.year.toString().padLeft(4, '0')}';

  static const _months = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  /// `out/25`.
  static String monthShort(LocalDate d) =>
      '${_months[d.month - 1]}/${_two(d.year % 100)}';

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// Agrupa milhares com `.` e usa `,` decimal, com [decimals] casas fixas.
  static String _group(Decimal value, int decimals) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final digits = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      buffer
        ..write(',')
        ..write(parts[1]);
    }
    return buffer.toString();
  }

  static final _decimalPattern = RegExp(r'^-?\d+(\.\d+)?$');

  /// Lê um número digitado: `1.234,56`, `1234,56`, `0.5` ou `1234`.
  ///
  /// Com vírgula, ela é a decimal e os pontos são de milhar. Sem vírgula, um
  /// único ponto é decimal; mais de um ponto são de milhar. Devolve `null`
  /// para texto vazio e lança [FormatException] para texto inválido.
  static Decimal? parseDecimal(String text) {
    var s = text.trim().replaceAll(' ', '').replaceAll(r'R$', '');
    if (s.isEmpty) return null;
    if (s.contains(',')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if ('.'.allMatches(s).length > 1) {
      s = s.replaceAll('.', '');
    }
    if (!_decimalPattern.hasMatch(s)) {
      throw FormatException('Número inválido', text);
    }
    return Decimal.parse(s);
  }

  static final _brDate = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');

  /// Lê `17/10/2026` ou `2026-10-17`. Lança [FormatException] se inválida.
  static LocalDate parseDate(String text) {
    final s = text.trim();
    final m = _brDate.firstMatch(s);
    if (m != null) {
      return LocalDate.parse(
        '${m.group(3)}-${m.group(2)!.padLeft(2, '0')}-'
        '${m.group(1)!.padLeft(2, '0')}',
      );
    }
    return LocalDate.parse(s);
  }
}
