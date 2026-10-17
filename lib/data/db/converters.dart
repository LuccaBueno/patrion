import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Grava `Decimal` como `TEXT` na representação canônica (DECISIONS D-03):
/// `3005.00` vira `"3005"` e `0.10` vira `"0.1"`. Nunca `REAL`.
class DecimalTextConverter extends TypeConverter<Decimal, String> {
  const DecimalTextConverter();

  @override
  Decimal fromSql(String fromDb) => Decimal.parse(fromDb);

  @override
  String toSql(Decimal value) => value.toString();
}
