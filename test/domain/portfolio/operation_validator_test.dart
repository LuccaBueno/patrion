import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/portfolio/operation_validator.dart';

Decimal d(String s) => Decimal.parse(s);

OperationDraft draft(
  OperationType type, {
  String? asset = 'a',
  String? qty,
  String? price,
  String? gross,
  String fees = '0',
  String? from,
  String? to,
  String? justification,
  String currency = 'BRL',
}) => OperationDraft(
  accountId: 'c',
  assetId: asset,
  type: type,
  tradeDate: LocalDate(2024, 1, 10),
  currency: currency,
  quantity: qty == null ? null : d(qty),
  unitPrice: price == null ? null : d(price),
  grossAmount: gross == null ? null : d(gross),
  fees: d(fees),
  ratioFrom: from == null ? null : d(from),
  ratioTo: to == null ? null : d(to),
  justification: justification,
);

Set<OperationField> fieldsOf(OperationDraft op) =>
    OperationValidator.validate(op).map((i) => i.field).toSet();

void main() {
  test('compra válida', () {
    expect(fieldsOf(draft(OperationType.buy, qty: '10', price: '5')), isEmpty);
  });

  test('compra sem ativo, quantidade e preço', () {
    expect(fieldsOf(draft(OperationType.buy, asset: null)), {
      OperationField.asset,
      OperationField.quantity,
      OperationField.unitPrice,
    });
  });

  test('depósito não pode ter ativo e precisa de valor', () {
    expect(fieldsOf(draft(OperationType.deposit)), {
      OperationField.asset,
      OperationField.grossAmount,
    });
    expect(
      fieldsOf(draft(OperationType.deposit, asset: null, gross: '1')),
      isEmpty,
    );
  });

  test('valores negativos só no ajuste manual', () {
    expect(
      fieldsOf(draft(OperationType.buy, qty: '-1', price: '5', fees: '-1')),
      containsAll([OperationField.quantity, OperationField.fees]),
    );
    expect(
      fieldsOf(
        draft(
          OperationType.manualAdjustment,
          qty: '-1',
          justification: 'Corretora corrigiu a custódia',
        ),
      ),
      isEmpty,
    );
  });

  test('ajuste manual exige justificativa e alguma variação', () {
    expect(fieldsOf(draft(OperationType.manualAdjustment)), {
      OperationField.justification,
      OperationField.grossAmount,
    });
  });

  test('desdobramento e grupamento conferem a proporção', () {
    expect(fieldsOf(draft(OperationType.split, from: '1', to: '2')), isEmpty);
    expect(fieldsOf(draft(OperationType.split, from: '2', to: '1')), {
      OperationField.ratio,
    });
    expect(
      fieldsOf(draft(OperationType.reverseSplit, from: '10', to: '1')),
      isEmpty,
    );
    expect(fieldsOf(draft(OperationType.reverseSplit, from: '1', to: '10')), {
      OperationField.ratio,
    });
    expect(fieldsOf(draft(OperationType.split)), {OperationField.ratio});
  });

  test('provento aceita valor total ou quantidade × valor por ação', () {
    expect(fieldsOf(draft(OperationType.dividend, gross: '45')), isEmpty);
    expect(
      fieldsOf(draft(OperationType.dividend, qty: '90', price: '0.5')),
      isEmpty,
    );
    expect(fieldsOf(draft(OperationType.dividend)), {
      OperationField.grossAmount,
    });
  });

  test('moeda precisa ser um código', () {
    expect(
      fieldsOf(draft(OperationType.buy, qty: '1', price: '1', currency: 'r\$')),
      {OperationField.currency},
    );
  });

  test('todos os tipos têm regra (nenhum passa vazio sem conta)', () {
    for (final type in OperationType.values) {
      final op = OperationDraft(
        accountId: '',
        type: type,
        tradeDate: LocalDate(2024, 1, 1),
        currency: 'BRL',
      );
      expect(fieldsOf(op), contains(OperationField.account), reason: type.code);
    }
  });
}
