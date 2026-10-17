import 'package:decimal/decimal.dart';

import '../../core/errors/app_error.dart';
import '../../core/time/local_date.dart';
import '../../data/repositories/portfolio_repositories.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/entities.dart';

/// Preços e saldos informados manualmente (SPEC §21, F3).
///
/// Um preço vale para o ativo em todas as contas; um saldo vale para uma
/// conta. Informar de novo na mesma data substitui o valor anterior.
class ValuationService {
  ValuationService(this._repos);

  final PortfolioRepositories _repos;

  /// Grava o preço unitário de [assetId] na data [refDate], na moeda do
  /// ativo.
  Future<String> setUnitPrice({
    required String assetId,
    required LocalDate refDate,
    required Decimal price,
    String? notes,
  }) => _put(
    assetId: assetId,
    accountId: null,
    kind: ValuationKind.unitPrice,
    refDate: refDate,
    value: price,
    notes: notes,
  );

  /// Grava o saldo de [assetId] na conta [accountId] na data [refDate].
  Future<String> setBalance({
    required String assetId,
    required String accountId,
    required LocalDate refDate,
    required Decimal balance,
    String? notes,
  }) => _put(
    assetId: assetId,
    accountId: accountId,
    kind: ValuationKind.balance,
    refDate: refDate,
    value: balance,
    notes: notes,
  );

  Future<void> delete(String id) => _repos.valuations.remove(id);

  Future<String> _put({
    required String assetId,
    required String? accountId,
    required ValuationKind kind,
    required LocalDate refDate,
    required Decimal value,
    required String? notes,
  }) => _repos.transaction(() async {
    if (value < Decimal.zero) {
      throw const DataError('O valor não pode ser negativo.');
    }
    final asset = await _repos.assets.byId(assetId);
    if (asset == null) throw const DataError('O ativo não existe.');
    if (accountId != null && await _repos.accounts.byId(accountId) == null) {
      throw const DataError('A conta não existe.');
    }
    final valuation = ManualValuation(
      id: '',
      assetId: assetId,
      accountId: accountId,
      refDate: refDate,
      kind: kind,
      value: value,
      currency: asset.currency,
      notes: notes,
    );
    final existing = await _repos.valuations.findSame(
      assetId: assetId,
      accountId: accountId,
      kind: kind,
      refDate: refDate,
    );
    if (existing == null) return _repos.valuations.create(valuation);
    await _repos.valuations.save(
      ManualValuation(
        id: existing.id,
        assetId: assetId,
        accountId: accountId,
        refDate: refDate,
        kind: kind,
        value: value,
        currency: asset.currency,
        notes: notes,
      ),
    );
    return existing.id;
  });
}
