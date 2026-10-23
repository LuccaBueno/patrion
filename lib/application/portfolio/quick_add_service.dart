import 'package:decimal/decimal.dart';

import '../../core/errors/app_error.dart';
import '../../core/time/local_date.dart';
import '../../data/repositories/portfolio_repositories.dart';
import '../../domain/portfolio/entities.dart';
import '../../domain/portfolio/operation_type.dart';
import 'operation_service.dart';
import 'registry_service.dart';

/// Dados do cadastro rápido (M-01): o ativo (já cadastrado ou novo), a
/// conta (existente ou criada junto) e a compra ou o saldo inicial.
class QuickAddInput {
  QuickAddInput({
    required this.quantity,
    required this.price,
    required this.date,
    this.assetId,
    this.newAsset,
    this.accountId,
    this.brokerName,
    this.initialBalance = false,
    this.offsetCash = false,
    Decimal? fees,
  }) : fees = fees ?? Decimal.zero;

  /// Ativo já cadastrado, ou [newAsset] para criar.
  final String? assetId;
  final Asset? newAsset;

  /// Conta existente, ou [brokerName]: a corretora com esse nome (criada,
  /// com a conta "Principal", se ainda não existir; M-06).
  final String? accountId;
  final String? brokerName;
  final Decimal quantity;

  /// Preço unitário da compra, ou o preço médio no saldo inicial.
  final Decimal price;
  final LocalDate date;
  final Decimal fees;

  /// Posição que o usuário já tinha (quantidade e preço médio da
  /// corretora), registrada como uma compra na data aproximada.
  final bool initialBalance;

  /// Registra também um depósito do mesmo valor, para o caixa não mudar
  /// (só faz sentido com o controle de caixa ligado, M-03).
  final bool offsetCash;
}

/// Ids gravados pelo cadastro rápido.
class QuickAddResult {
  const QuickAddResult({
    required this.assetId,
    required this.accountId,
    required this.outcome,
  });

  final String assetId;
  final String accountId;

  /// [Saved] ou [PossibleDuplicate] (nada gravado).
  final SaveOutcome outcome;
}

/// Cria o ativo (se preciso), a conta (se não houver) e a compra numa
/// transação só: ou grava tudo, ou nada.
class QuickAddService {
  QuickAddService(this._repos, this._registry, this._operations);

  final PortfolioRepositories _repos;
  final RegistryService _registry;
  final OperationService _operations;

  /// Nota gravada na compra que representa o saldo inicial.
  static const initialBalanceNote = InitialBalance.note;

  Future<QuickAddResult> add(
    QuickAddInput input, {
    bool allowDuplicate = false,
  }) => _repos.transaction(() async {
    if (input.quantity <= Decimal.zero) {
      throw const DataError('Informe uma quantidade maior que zero.');
    }
    if (input.price <= Decimal.zero) {
      throw const DataError('Informe um preço maior que zero.');
    }
    final accountId =
        input.accountId ??
        await _registry.accountForBroker(input.brokerName ?? '');
    final String assetId;
    final String currency;
    final existing = input.assetId;
    if (existing != null) {
      final asset = await _repos.assets.byId(existing);
      if (asset == null) throw const DataError('O ativo não existe mais.');
      assetId = existing;
      currency = asset.currency;
    } else {
      final asset = input.newAsset;
      if (asset == null) throw const DataError('Informe o ativo.');
      assetId = await _registry.createAsset(asset);
      currency = asset.currency;
    }
    final buy = OperationDraft(
      accountId: accountId,
      assetId: assetId,
      type: OperationType.buy,
      tradeDate: input.date,
      currency: currency,
      quantity: input.quantity,
      unitPrice: input.price,
      fees: input.fees,
      notes: input.initialBalance ? initialBalanceNote : null,
    );
    // Ativo novo não tem operações: não há duplicata possível.
    final outcome = await _operations.save(
      buy,
      allowDuplicate: allowDuplicate || existing == null,
    );
    if (outcome is Saved && input.offsetCash) {
      await _operations.save(
        OperationDraft(
          accountId: accountId,
          type: OperationType.deposit,
          tradeDate: input.date,
          currency: currency,
          grossAmount: buy.amount + buy.charges,
          notes: 'Depósito para o saldo inicial não mudar o caixa',
        ),
        allowDuplicate: true,
      );
    }
    return QuickAddResult(
      assetId: assetId,
      accountId: accountId,
      outcome: outcome,
    );
  });
}
