import 'package:decimal/decimal.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/json/exact_json.dart';
import '../../../core/time/local_date.dart';

/// Leitura dos formatos dos provedores. Toda falha vira [DataError] com o
/// nome do provedor, sem o conteúdo (que pode ser grande).
abstract final class MarketParse {
  static Never invalid(String provider, String detail) => throw DataError(
    detail == 'página HTML'
        ? '$provider respondeu com uma página de erro em vez dos dados: o '
              'serviço pode estar fora do ar ou ter mudado. Os dados já '
              'baixados continuam disponíveis.'
        : 'A resposta de $provider veio num formato inesperado ($detail). O '
              'provedor pode ter mudado; os dados já baixados continuam '
              'disponíveis.',
  );

  /// JSON com números exatos.
  static Object? json(String provider, String text) {
    try {
      return ExactJson.decode(text);
    } on FormatException {
      invalid(provider, 'JSON ilegível');
    }
  }

  /// Decimal de texto ("1.234,56", "0,47", "5.6147") ou de [JsonNumber].
  /// Vazio, "-" ou nulo viram `null`.
  static Decimal? decimal(Object? value, {bool brazilian = false}) {
    if (value == null) return null;
    if (value is JsonNumber) return value.decimal;
    var text = '$value'.trim();
    if (text.isEmpty || text == '-' || text == '--') return null;
    if (brazilian) {
      text = text.replaceAll('.', '').replaceAll(',', '.');
    }
    return Decimal.tryParse(text);
  }

  /// `dd/MM/aaaa`.
  static LocalDate? brDate(Object? value) {
    if (value == null) return null;
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})').firstMatch('$value'.trim());
    if (m == null) return null;
    try {
      return LocalDate(
        int.parse(m.group(3)!),
        int.parse(m.group(2)!),
        int.parse(m.group(1)!),
      );
    } on ArgumentError {
      return null;
    }
  }

  /// `aaaa-MM-dd` (com ou sem hora depois).
  static LocalDate? isoDate(Object? value) {
    if (value == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch('$value'.trim());
    if (m == null) return null;
    try {
      return LocalDate(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      );
    } on ArgumentError {
      return null;
    }
  }

  /// `dd/MM/aaaa` para os parâmetros do SGS.
  static String brFormat(LocalDate d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year}';

  /// `MM-dd-aaaa` para o PTAX.
  static String usFormat(LocalDate d) =>
      '${_two(d.month)}-${_two(d.day)}-${d.year}';

  static String _two(int v) => v.toString().padLeft(2, '0');

  static List<Object?> list(String provider, Object? value, String what) {
    if (value is List<Object?>) return value;
    invalid(provider, '$what não é uma lista');
  }

  static Map<String, Object?> map(String provider, Object? value, String what) {
    if (value is Map<String, Object?>) return value;
    invalid(provider, '$what não é um objeto');
  }
}
