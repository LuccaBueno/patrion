import 'package:decimal/decimal.dart';
import 'package:patrion/application/portfolio/operation_service.dart';
import 'package:patrion/application/portfolio/portfolio_query.dart';
import 'package:patrion/application/portfolio/registry_service.dart';
import 'package:patrion/application/portfolio/valuation_service.dart';
import 'package:patrion/application/settings/portfolio_preferences.dart';
import 'package:patrion/data/repositories/shared_settings_repository.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/portfolio_repositories.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';

import 'test_database.dart';

Decimal dec(String s) => Decimal.parse(s);

/// Serviços da carteira sobre um banco de teste, com uma instituição, duas
/// contas e dois ativos já cadastrados.
class PortfolioFixture {
  PortfolioFixture._(this.t)
    : repos = PortfolioRepositories(t.db, t.sync),
      registry = RegistryService(
        PortfolioRepositories(t.db, t.sync),
        wallClock: t.wall.clock,
      ),
      operations = OperationService(PortfolioRepositories(t.db, t.sync)),
      valuations = ValuationService(PortfolioRepositories(t.db, t.sync)),
      preferences = PortfolioPreferences(
        SharedSettingsRepository(t.db, t.sync),
      ),
      query = PortfolioQuery(
        PortfolioRepositories(t.db, t.sync),
        wallClock: t.wall.clock,
        preferences: PortfolioPreferences(
          SharedSettingsRepository(t.db, t.sync),
        ),
      );

  final TestDb t;
  final PortfolioRepositories repos;
  final RegistryService registry;
  final OperationService operations;
  final ValuationService valuations;
  final PortfolioQuery query;

  /// Controle de caixa (M-03), desligado por padrão como no app.
  final PortfolioPreferences preferences;

  late String broker;
  late String account;
  late String account2;
  late String petr;
  late String cdb;

  static Future<PortfolioFixture> open({TestDb? db}) async {
    final f = PortfolioFixture._(db ?? await TestDb.open());
    await f._seed();
    return f;
  }

  Future<void> _seed() async {
    broker = await registry.createInstitution(
      const Institution(
        id: '',
        name: 'Corretora Exemplo',
        kind: InstitutionKind.broker,
        country: 'BR',
      ),
    );
    account = await registry.createAccount(
      Account(
        id: '',
        institutionId: broker,
        name: 'Principal',
        kind: AccountKind.brokerage,
        currency: 'BRL',
      ),
    );
    account2 = await registry.createAccount(
      Account(
        id: '',
        institutionId: broker,
        name: 'Secundária',
        kind: AccountKind.brokerage,
        currency: 'BRL',
      ),
    );
    petr = await registry.createAsset(
      const Asset(
        id: '',
        symbol: 'PETR4',
        market: Market.b3,
        assetClass: AssetClass.stockBr,
        name: 'Petrobras PN',
        currency: 'BRL',
        country: 'BR',
      ),
    );
    cdb = await registry.createAsset(
      const Asset(
        id: '',
        symbol: 'CDB-EXEMPLO-2026',
        market: Market.manual,
        assetClass: AssetClass.fixedIncome,
        name: 'CDB Exemplo',
        currency: 'BRL',
        country: 'BR',
      ),
      terms: FixedIncomeTerms(
        assetId: '',
        product: FixedIncomeProduct.cdb,
        indexer: Indexer.cdi,
        rate: dec('110'),
        dayCount: DayCount.bus252,
        issueDate: LocalDate(2024, 1, 2),
        maturityDate: LocalDate(2026, 12, 1),
        liquidity: Liquidity.atMaturity,
        taxRegime: TaxRegime.regressiveIr,
      ),
    );
  }

  /// Operação com valores em texto, na conta principal e em PETR4.
  OperationDraft draft(
    OperationType type,
    String date, {
    String? account,
    String? asset = '',
    String? qty,
    String? price,
    String? gross,
    String fees = '0',
    String? from,
    String? to,
    String? justification,
  }) => OperationDraft(
    accountId: account ?? this.account,
    assetId: asset == '' ? petr : asset,
    type: type,
    tradeDate: LocalDate.parse(date),
    currency: 'BRL',
    quantity: qty == null ? null : dec(qty),
    unitPrice: price == null ? null : dec(price),
    grossAmount: gross == null ? null : dec(gross),
    fees: dec(fees),
    ratioFrom: from == null ? null : dec(from),
    ratioTo: to == null ? null : dec(to),
    justification: justification,
  );

  /// Grava e devolve o id, falhando o teste se não for gravada.
  Future<String> add(OperationDraft d) async {
    final outcome = await operations.save(d, allowDuplicate: true);
    return (outcome as Saved).id;
  }
}
