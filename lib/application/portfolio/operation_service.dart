import 'package:decimal/decimal.dart';

import '../../core/errors/app_error.dart';
import '../../core/time/local_date.dart';
import '../../data/repositories/portfolio_repositories.dart';
import '../../domain/portfolio/entities.dart';
import '../../domain/portfolio/operation_type.dart';
import '../../domain/portfolio/operation_validator.dart';
import '../../domain/portfolio/portfolio_calculator.dart';

/// Resultado de [OperationService.save].
sealed class SaveOutcome {
  const SaveOutcome();
}

/// Gravada.
final class Saved extends SaveOutcome {
  const Saved(this.id);

  final String id;
}

/// Não gravada: parece repetir operações já registradas. Gravar mesmo assim
/// exige `allowDuplicate: true`.
final class PossibleDuplicate extends SaveOutcome {
  const PossibleDuplicate(this.matches);

  final List<Operation> matches;
}

/// Dados de uma transferência entre contas (duas operações ligadas por
/// `transfer_group_id`).
class TransferInput {
  TransferInput({
    required this.fromAccountId,
    required this.toAccountId,
    required this.date,
    required this.currency,
    this.assetId,
    this.quantity,
    this.amount,
    Decimal? fees,
    this.notes,
  }) : fees = fees ?? Decimal.zero;

  final String fromAccountId;
  final String toAccountId;
  final LocalDate date;
  final String currency;

  /// Com ativo: transferência de custódia (usa [quantity]). Sem ativo:
  /// transferência de caixa (usa [amount]).
  final String? assetId;
  final Decimal? quantity;
  final Decimal? amount;

  /// Custos, cobrados na conta de origem.
  final Decimal fees;
  final String? notes;
}

/// Grava, altera e exclui operações da carteira real (SPEC §7).
///
/// Antes de gravar:
/// 1. confere o preenchimento ([OperationValidator]);
/// 2. confere conta, ativo e moeda;
/// 3. procura duplicatas (só em operações novas);
/// 4. recalcula a carteira com a alteração e recusa o que deixaria uma
///    posição negativa ou uma transferência sem uma das pontas.
///
/// Como posições e métricas são recalculadas a partir das operações, editar
/// uma operação antiga atualiza tudo o que vem depois dela.
class OperationService {
  OperationService(this._repos);

  final PortfolioRepositories _repos;

  /// Grava a operação nova (sem [id]) ou altera a existente.
  ///
  /// Lança [ValidationFailure] com os problemas encontrados. Transferências
  /// usam [saveTransfer].
  Future<SaveOutcome> save(
    OperationDraft draft, {
    String? id,
    bool allowDuplicate = false,
  }) => _repos.transaction(() async {
    if (draft.type.isTransfer) {
      throw const DataError('Use a tela de transferência.');
    }
    Operation? previous;
    if (id != null) {
      previous = await _repos.operations.byId(id);
      if (previous == null) {
        throw const DataError('A operação não existe mais.');
      }
      if (previous.type.isTransfer) {
        throw const DataError('Use a tela de transferência.');
      }
    }
    await _checkDraft(draft);

    if (id == null && !allowDuplicate) {
      final matches = await _duplicatesOf(draft);
      if (matches.isNotEmpty) return PossibleDuplicate(matches);
    }

    final candidate = _asOperation(id ?? _repos.newId(), draft);
    await _checkConsistency(replacing: {?id}, adding: [candidate]);

    if (id == null) return Saved(await _repos.operations.create(draft));
    await _repos.operations.save(id, draft);
    return Saved(id);
  });

  /// Cria a transferência ou, com [groupId], altera as duas pontas dela.
  /// Devolve o `transfer_group_id`.
  Future<String> saveTransfer(TransferInput input, {String? groupId}) =>
      _repos.transaction(() async {
        if (input.fromAccountId == input.toAccountId) {
          throw const ValidationFailure([
            ValidationIssue(
              OperationField.account,
              'Escolha contas diferentes para origem e destino.',
            ),
          ]);
        }
        final group = groupId ?? _repos.newId();
        final out = OperationDraft(
          accountId: input.fromAccountId,
          assetId: input.assetId,
          type: OperationType.transferOut,
          tradeDate: input.date,
          currency: input.currency,
          quantity: input.assetId == null ? null : input.quantity,
          grossAmount: input.assetId == null ? input.amount : null,
          fees: input.fees,
          transferGroupId: group,
          notes: input.notes,
        );
        final into = OperationDraft(
          accountId: input.toAccountId,
          assetId: input.assetId,
          type: OperationType.transferIn,
          tradeDate: input.date,
          currency: input.currency,
          quantity: input.assetId == null ? null : input.quantity,
          grossAmount: input.assetId == null ? input.amount : null,
          transferGroupId: group,
          notes: input.notes,
        );
        await _checkDraft(out);
        await _checkDraft(into);

        final legs = groupId == null
            ? const <Operation>[]
            : await _repos.operations.ofTransferGroup(groupId);
        final oldOut = legs.where((o) => o.type == OperationType.transferOut);
        final oldIn = legs.where((o) => o.type == OperationType.transferIn);
        if (groupId != null && (oldOut.length != 1 || oldIn.length != 1)) {
          throw const DataError('A transferência não existe mais.');
        }
        final outId = groupId == null ? _repos.newId() : oldOut.single.id;
        final inId = groupId == null ? _repos.newId() : oldIn.single.id;
        await _checkConsistency(
          replacing: {for (final l in legs) l.id},
          adding: [_asOperation(outId, out), _asOperation(inId, into)],
        );

        if (groupId == null) {
          await _repos.operations.create(out);
          await _repos.operations.create(into);
        } else {
          await _repos.operations.save(outId, out);
          await _repos.operations.save(inId, into);
        }
        return group;
      });

  /// Exclui a operação (tombstone). Numa transferência, exclui as duas
  /// pontas. Recusa se a exclusão deixar alguma posição negativa.
  Future<void> delete(String id) => _repos.transaction(() async {
    final op = await _repos.operations.byId(id);
    if (op == null) return;
    final group = op.transferGroupId;
    final ids = op.type.isTransfer && group != null
        ? {for (final l in await _repos.operations.ofTransferGroup(group)) l.id}
        : {id};
    await _checkConsistency(replacing: ids, adding: const []);
    for (final legId in ids) {
      await _repos.operations.remove(legId);
    }
  });

  Future<void> _checkDraft(OperationDraft draft) async {
    final issues = OperationValidator.validate(draft);
    final account = await _repos.accounts.byId(draft.accountId);
    if (draft.accountId.isNotEmpty && account == null) {
      issues.add(
        const ValidationIssue(OperationField.account, 'A conta não existe.'),
      );
    }
    final assetId = draft.assetId;
    if (assetId != null) {
      final asset = await _repos.assets.byId(assetId);
      if (asset == null) {
        issues.add(
          const ValidationIssue(OperationField.asset, 'O ativo não existe.'),
        );
      } else if (asset.currency != draft.currency) {
        issues.add(
          ValidationIssue(
            OperationField.currency,
            'A moeda da operação deve ser a do ativo (${asset.currency}).',
          ),
        );
      }
    }
    if (issues.isNotEmpty) throw ValidationFailure(issues);
  }

  /// Operações vivas iguais em conta, ativo, tipo, data, quantidade, preço
  /// e valor.
  Future<List<Operation>> _duplicatesOf(OperationDraft d) async {
    final all = await _repos.operations.all();
    return [
      for (final o in all)
        if (o.accountId == d.accountId &&
            o.assetId == d.assetId &&
            o.type == d.type &&
            o.tradeDate == d.tradeDate &&
            o.quantity == d.quantity &&
            o.unitPrice == d.unitPrice &&
            o.amount == d.amount)
          o,
    ];
  }

  /// Recalcula a carteira com a alteração e recusa inconsistências novas.
  Future<void> _checkConsistency({
    required Set<String> replacing,
    required List<Operation> adding,
  }) async {
    final current = await _repos.operations.all();
    final before = PortfolioCalculator.compute(operations: current).issues;
    final after = PortfolioCalculator.compute(
      operations: [
        for (final o in current)
          if (!replacing.contains(o.id)) o,
        ...adding,
      ],
    ).issues;

    String keyOf(PortfolioIssue i) => '${i.kind.name}|${i.operationId}';
    final known = before.map(keyOf).toSet();
    final fresh = [
      for (final i in after)
        if (!known.contains(keyOf(i)) &&
            i.kind != PortfolioIssueKind.currencyMismatch)
          i,
    ];
    if (fresh.isEmpty) return;

    final messages = <ValidationIssue>[];
    for (final issue in fresh) {
      messages.add(switch (issue.kind) {
        PortfolioIssueKind.oversold => ValidationIssue(
          OperationField.quantity,
          'A posição ficaria negativa em ${_br(issue.date)}: a quantidade '
          'vendida ou transferida é maior que a disponível na conta.',
        ),
        PortfolioIssueKind.missingTransferLeg => ValidationIssue(
          OperationField.account,
          'Transferência sem a ponta de saída em ${_br(issue.date)}.',
        ),
        PortfolioIssueKind.unknownAsset ||
        PortfolioIssueKind.currencyMismatch => ValidationIssue(
          OperationField.asset,
          'Operação inconsistente em ${_br(issue.date)}.',
        ),
      });
    }
    throw ValidationFailure(messages);
  }

  static String _br(LocalDate d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  static Operation _asOperation(String id, OperationDraft d) => Operation(
    id: id,
    accountId: d.accountId,
    assetId: d.assetId,
    type: d.type,
    tradeDate: d.tradeDate,
    settlementDate: d.settlementDate,
    quantity: d.quantity,
    unitPrice: d.unitPrice,
    grossAmount: d.grossAmount,
    fees: d.fees,
    taxes: d.taxes,
    currency: d.currency,
    fxRate: d.fxRate,
    ratioFrom: d.ratioFrom,
    ratioTo: d.ratioTo,
    transferGroupId: d.transferGroupId,
    relatedOperationId: d.relatedOperationId,
    justification: d.justification,
    notes: d.notes,
    origin: d.origin,
  );
}
