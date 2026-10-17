import 'package:clock/clock.dart';

import '../../core/errors/app_error.dart';
import '../../core/time/instant_format.dart';
import '../../data/repositories/portfolio_repositories.dart';
import '../../domain/portfolio/entities.dart';

/// Cadastros da carteira real: instituições, contas e ativos (SPEC §6).
///
/// Aplica as chaves naturais (`docs/BANCO.md` §2) e impede excluir um
/// cadastro ainda em uso. Mensagens de erro vão para a tela, em
/// [DataError].
class RegistryService {
  RegistryService(this._repos, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final PortfolioRepositories _repos;
  final Clock _clock;

  static final _currencyPattern = RegExp(r'^[A-Z0-9]{3,10}$');
  static final _countryPattern = RegExp(r'^[A-Z]{2}$');

  // -- Instituições ---------------------------------------------------------

  Future<String> createInstitution(Institution value) =>
      _repos.transaction(() async {
        await _checkInstitution(value);
        return _repos.institutions.create(value);
      });

  Future<void> updateInstitution(Institution value) =>
      _repos.transaction(() async {
        await _checkInstitution(value);
        await _repos.institutions.save(value);
      });

  Future<void> deleteInstitution(String id) => _repos.transaction(() async {
    if ((await _repos.accounts.ofInstitution(id)).isNotEmpty) {
      throw const DataError(
        'A instituição tem contas. Exclua ou mova as contas antes.',
      );
    }
    await _repos.institutions.remove(id);
  });

  Future<void> _checkInstitution(Institution value) async {
    if (value.name.trim().isEmpty) {
      throw const DataError('Informe o nome da instituição.');
    }
    if (!_countryPattern.hasMatch(value.country)) {
      throw const DataError('País inválido (use o código, ex.: BR).');
    }
    final same = await _repos.institutions.findByNameKey(value.nameKey);
    if (same.any((i) => i.id != value.id)) {
      throw const DataError('Já existe uma instituição com esse nome.');
    }
  }

  // -- Contas ---------------------------------------------------------------

  Future<String> createAccount(Account value) => _repos.transaction(() async {
    await _checkAccount(value);
    return _repos.accounts.create(value);
  });

  Future<void> updateAccount(Account value) => _repos.transaction(() async {
    await _checkAccount(value);
    final previous = await _repos.accounts.archivedAt(value.id);
    final archivedAt = value.archived
        ? (previous ?? formatInstant(_clock.now()))
        : null;
    await _repos.accounts.save(value, archivedAt: archivedAt);
  });

  Future<void> deleteAccount(String id) => _repos.transaction(() async {
    if (await _repos.operations.anyForAccount(id)) {
      throw const DataError(
        'A conta tem operações. Exclua as operações ou arquive a conta.',
      );
    }
    await _repos.accounts.remove(id);
  });

  Future<void> _checkAccount(Account value) async {
    if (value.name.trim().isEmpty) {
      throw const DataError('Informe o nome da conta.');
    }
    if (!_currencyPattern.hasMatch(value.currency)) {
      throw const DataError('Moeda inválida (use o código, ex.: BRL).');
    }
    final siblings = await _repos.accounts.ofInstitution(value.institutionId);
    final key = normalizeNameKey(value.name);
    if (siblings.any(
      (a) => a.id != value.id && normalizeNameKey(a.name) == key,
    )) {
      throw const DataError(
        'Já existe uma conta com esse nome nesta '
        'instituição.',
      );
    }
  }

  // -- Ativos ---------------------------------------------------------------

  /// Cria o ativo e, para renda fixa, as características em [terms].
  Future<String> createAsset(Asset value, {FixedIncomeTerms? terms}) =>
      _repos.transaction(() async {
        await _checkAsset(value, terms);
        final id = await _repos.assets.create(value);
        if (terms != null) await _repos.fixedIncome.put(_withAsset(terms, id));
        return id;
      });

  Future<void> updateAsset(Asset value, {FixedIncomeTerms? terms}) =>
      _repos.transaction(() async {
        await _checkAsset(value, terms);
        await _repos.assets.save(value);
        if (terms != null) {
          await _repos.fixedIncome.put(_withAsset(terms, value.id));
        } else {
          await _repos.fixedIncome.removeFor(value.id);
        }
      });

  /// Exclui o ativo (tombstone), com suas características e preços.
  Future<void> deleteAsset(String id) => _repos.transaction(() async {
    if (await _repos.operations.anyForAsset(id)) {
      throw const DataError(
        'O ativo tem operações. Exclua as operações antes.',
      );
    }
    await _repos.fixedIncome.removeFor(id);
    for (final v in await _repos.valuations.all()) {
      if (v.assetId == id) await _repos.valuations.remove(v.id);
    }
    await _repos.assets.remove(id);
  });

  Future<void> _checkAsset(Asset value, FixedIncomeTerms? terms) async {
    if (value.symbol.trim().isEmpty) {
      throw const DataError('Informe o código do ativo.');
    }
    if (value.name.trim().isEmpty) {
      throw const DataError('Informe o nome do ativo.');
    }
    if (!_currencyPattern.hasMatch(value.currency)) {
      throw const DataError('Moeda inválida (use o código, ex.: BRL).');
    }
    if (!_countryPattern.hasMatch(value.country)) {
      throw const DataError('País inválido (use o código, ex.: BR).');
    }
    if (value.assetClass.hasFixedIncomeTerms && terms == null) {
      throw const DataError('Informe as características do título.');
    }
    if (!value.assetClass.hasFixedIncomeTerms && terms != null) {
      throw const DataError('Só renda fixa tem características de título.');
    }
    if (terms != null && terms.maturityDate.isBefore(terms.issueDate)) {
      throw const DataError('O vencimento não pode ser antes da emissão.');
    }
    final same = await _repos.assets.findBySymbol(value.symbol, value.market);
    if (same.any((a) => a.id != value.id && a.naturalKey == value.naturalKey)) {
      throw const DataError(
        'Já existe um ativo com esse código, mercado e classe.',
      );
    }
  }

  static FixedIncomeTerms _withAsset(FixedIncomeTerms t, String assetId) =>
      FixedIncomeTerms(
        assetId: assetId,
        product: t.product,
        issuer: t.issuer,
        indexer: t.indexer,
        rate: t.rate,
        spread: t.spread,
        dayCount: t.dayCount,
        issueDate: t.issueDate,
        maturityDate: t.maturityDate,
        graceUntil: t.graceUntil,
        liquidity: t.liquidity,
        taxRegime: t.taxRegime,
        costsNotes: t.costsNotes,
      );
}
