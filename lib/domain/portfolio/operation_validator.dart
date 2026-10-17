import 'package:decimal/decimal.dart';

import 'entities.dart';
import 'operation_type.dart';

/// Campo do formulário a que um problema se refere.
enum OperationField {
  account,
  asset,
  quantity,
  unitPrice,
  grossAmount,
  fees,
  taxes,
  currency,
  fxRate,
  ratio,
  settlementDate,
  justification,
}

/// Problema de validação, com mensagem para o usuário.
class ValidationIssue {
  const ValidationIssue(this.field, this.message);

  final OperationField field;
  final String message;

  @override
  String toString() => '${field.name}: $message';
}

/// Operação recusada por problemas de preenchimento ou de consistência.
class ValidationFailure implements Exception {
  const ValidationFailure(this.issues);

  final List<ValidationIssue> issues;

  String get message => issues.map((i) => i.message).join('\n');

  @override
  String toString() => 'ValidationFailure: $issues';
}

/// Regras de preenchimento de cada tipo de operação (SPEC §7).
///
/// Só confere a operação isolada. Regras que dependem das demais (vender
/// mais do que a posição) ficam no serviço de operações, que recalcula a
/// carteira.
abstract final class OperationValidator {
  static final _zero = Decimal.zero;
  static final _currencyPattern = RegExp(r'^[A-Z0-9]{3,10}$');

  static List<ValidationIssue> validate(OperationDraft op) {
    final issues = <ValidationIssue>[];
    void add(OperationField f, String m) => issues.add(ValidationIssue(f, m));

    final type = op.type;
    final adjustment = type == OperationType.manualAdjustment;

    if (op.accountId.isEmpty) add(OperationField.account, 'Escolha a conta.');

    switch (type.assetUse) {
      case AssetUse.required when op.assetId == null:
        add(OperationField.asset, 'Escolha o ativo.');
      case AssetUse.none when op.assetId != null:
        add(OperationField.asset, 'Este tipo não se refere a um ativo.');
      default:
        break;
    }

    if (!_currencyPattern.hasMatch(op.currency)) {
      add(OperationField.currency, 'Moeda inválida (use o código, ex.: BRL).');
    }

    // Sinais: só o ajuste manual aceita quantidade e valor negativos.
    if (!adjustment) {
      if (op.quantity != null && op.quantity! < _zero) {
        add(OperationField.quantity, 'A quantidade não pode ser negativa.');
      }
      if (op.grossAmount != null && op.grossAmount! < _zero) {
        add(OperationField.grossAmount, 'O valor não pode ser negativo.');
      }
    }
    if (op.unitPrice != null && op.unitPrice! < _zero) {
      add(OperationField.unitPrice, 'O preço não pode ser negativo.');
    }
    if (op.fees < _zero) {
      add(OperationField.fees, 'Os custos não podem ser negativos.');
    }
    if (op.taxes < _zero) {
      add(OperationField.taxes, 'Os impostos não podem ser negativos.');
    }
    if (op.fxRate != null && op.fxRate! <= _zero) {
      add(OperationField.fxRate, 'O câmbio precisa ser maior que zero.');
    }
    if (op.settlementDate != null &&
        op.settlementDate!.isBefore(op.tradeDate)) {
      add(
        OperationField.settlementDate,
        'A liquidação não pode ser antes da data da operação.',
      );
    }

    final hasPositiveQuantity = op.quantity != null && op.quantity! > _zero;
    final hasPositiveAmount = op.amount > _zero;

    if (type.requiresQuantity && !hasPositiveQuantity) {
      add(OperationField.quantity, 'Informe a quantidade.');
    }

    switch (type) {
      case OperationType.buy ||
          OperationType.sell ||
          OperationType.reinvestment:
        if (op.unitPrice == null && op.grossAmount == null) {
          add(OperationField.unitPrice, 'Informe o preço ou o valor total.');
        }
      case OperationType.contribution ||
          OperationType.redemption ||
          OperationType.deposit ||
          OperationType.withdrawal ||
          OperationType.dividend ||
          OperationType.jcp ||
          OperationType.fiiIncome ||
          OperationType.interest ||
          OperationType.amortization ||
          OperationType.fee ||
          OperationType.tax ||
          OperationType.withholding:
        if (!hasPositiveAmount) {
          add(OperationField.grossAmount, 'Informe o valor.');
        }
      case OperationType.transferOut || OperationType.transferIn:
        if (op.assetId != null && !hasPositiveQuantity) {
          add(OperationField.quantity, 'Informe a quantidade transferida.');
        }
        if (op.assetId == null && !hasPositiveAmount) {
          add(OperationField.grossAmount, 'Informe o valor transferido.');
        }
      case OperationType.split || OperationType.reverseSplit:
        final from = op.ratioFrom;
        final to = op.ratioTo;
        if (from == null || to == null || from <= _zero || to <= _zero) {
          add(OperationField.ratio, 'Informe a proporção (ex.: 1 para 2).');
        } else if (type == OperationType.split && to <= from) {
          add(
            OperationField.ratio,
            'No desdobramento a quantidade aumenta (ex.: 1 para 2).',
          );
        } else if (type == OperationType.reverseSplit && to >= from) {
          add(
            OperationField.ratio,
            'No grupamento a quantidade diminui (ex.: 10 para 1).',
          );
        }
      case OperationType.manualAdjustment:
        if ((op.justification ?? '').trim().isEmpty) {
          add(
            OperationField.justification,
            'O ajuste manual precisa de justificativa.',
          );
        }
        final quantityChange = op.quantity ?? _zero;
        final valueChange = op.grossAmount ?? _zero;
        if (quantityChange == _zero && valueChange == _zero) {
          add(
            OperationField.grossAmount,
            'Informe a variação de quantidade ou de valor.',
          );
        }
      case OperationType.bonusShares || OperationType.maturity:
        break;
    }
    return issues;
  }
}
