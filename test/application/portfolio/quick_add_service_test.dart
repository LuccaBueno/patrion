import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/portfolio/operation_service.dart';
import 'package:patrion/application/portfolio/quick_add_service.dart';
import 'package:patrion/application/portfolio/registry_service.dart';
import 'package:patrion/data/repositories/portfolio_repositories.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/portfolio/operation_validator.dart';

import '../../helpers/portfolio_fixture.dart';
import '../../helpers/test_database.dart';

Asset _bbas3() => const Asset(
  id: '',
  symbol: 'BBAS3',
  market: Market.b3,
  assetClass: AssetClass.stockBr,
  name: 'Banco do Brasil S.A.',
  currency: 'BRL',
  country: 'BR',
  priceSource: PriceSource.market,
);

/// Cadastro rápido (M-01): ativo, conta e compra numa transação só.
void main() {
  group('com cadastros', () {
    late PortfolioFixture f;
    late QuickAddService service;

    setUp(() async {
      f = await PortfolioFixture.open();
      service = QuickAddService(f.repos, f.registry, f.operations);
    });

    tearDown(() => f.t.close());

    test('ativo novo: cria o ativo e a compra em uma operação', () async {
      final result = await service.add(
        QuickAddInput(
          newAsset: _bbas3(),
          accountId: f.account,
          quantity: dec('100'),
          price: dec('25'),
          date: LocalDate(2026, 10, 22),
        ),
      );
      expect(result.outcome, isA<Saved>());
      final asset = (await f.repos.assets.byId(result.assetId))!;
      expect(asset.symbol, 'BBAS3');
      expect(asset.assetClass, AssetClass.stockBr);
      final ops = (await f.repos.operations.all())
          .where((o) => o.assetId == result.assetId)
          .toList();
      expect(ops.single.type, OperationType.buy);
      expect(ops.single.quantity, dec('100'));
      expect(ops.single.unitPrice, dec('25'));
      expect(ops.single.amount, dec('2500'));
      expect(ops.single.notes, isNull);
    });

    test('ativo já cadastrado: só registra a compra; repetida, avisa '
        'duplicata sem gravar', () async {
      QuickAddInput input() => QuickAddInput(
        assetId: f.petr,
        accountId: f.account,
        quantity: dec('10'),
        price: dec('30'),
        date: LocalDate(2026, 10, 22),
        fees: dec('4.90'),
      );
      final assetsBefore = (await f.repos.assets.all()).length;
      final first = await service.add(input());
      expect(first.outcome, isA<Saved>());
      expect((await f.repos.assets.all()).length, assetsBefore);
      final op = (await f.repos.operations.all()).single;
      expect(op.fees, dec('4.90'));

      final again = await service.add(input());
      expect(again.outcome, isA<PossibleDuplicate>());
      expect(await f.repos.operations.all(), hasLength(1));
      await service.add(input(), allowDuplicate: true);
      expect(await f.repos.operations.all(), hasLength(2));
    });

    test('saldo inicial: compra na data aproximada com a nota; com o caixa '
        'ligado, o depósito do mesmo valor mantém o caixa', () async {
      final result = await service.add(
        QuickAddInput(
          newAsset: _bbas3(),
          accountId: f.account,
          quantity: dec('100'),
          price: dec('22.5'),
          date: LocalDate(2025, 1, 2),
          initialBalance: true,
          offsetCash: true,
        ),
      );
      final ops = await f.repos.operations.all();
      final buy = ops.firstWhere((o) => o.type == OperationType.buy);
      expect(buy.assetId, result.assetId);
      expect(buy.notes, QuickAddService.initialBalanceNote);
      final deposit = ops.firstWhere((o) => o.type == OperationType.deposit);
      expect(deposit.grossAmount, dec('2250'));
      expect(deposit.tradeDate, LocalDate(2025, 1, 2));
      final snap = await f.query.load();
      expect(snap.state.cash[f.account]?['BRL'] ?? dec('0'), dec('0'));
    });

    test('falha no meio não deixa nada gravado', () async {
      final assetsBefore = (await f.repos.assets.all()).length;
      // Conta inexistente: a compra é recusada depois de o ativo ser criado.
      await expectLater(
        service.add(
          QuickAddInput(
            newAsset: _bbas3(),
            accountId: 'nao-existe',
            quantity: dec('1'),
            price: dec('10'),
            date: LocalDate(2026, 10, 22),
          ),
        ),
        throwsA(isA<ValidationFailure>()),
      );
      expect(await f.repos.assets.all(), hasLength(assetsBefore));
      await expectLater(
        service.add(
          QuickAddInput(
            assetId: f.petr,
            accountId: f.account,
            quantity: dec('0'),
            price: dec('10'),
            date: LocalDate(2026, 10, 22),
          ),
        ),
        throwsA(isA<DataError>()),
      );
    });
  });

  test('sem conta: cria a instituição e a "Conta principal"', () async {
    final t = await TestDb.open();
    addTearDown(t.close);
    final repos = PortfolioRepositories(t.db, t.sync);
    final empty = QuickAddService(
      repos,
      RegistryService(repos),
      OperationService(repos),
    );
    final result = await empty.add(
      QuickAddInput(
        newAsset: _bbas3(),
        newInstitutionName: 'Minha Corretora',
        quantity: dec('1'),
        price: dec('10'),
        date: LocalDate(2026, 10, 22),
      ),
    );
    final account = (await repos.accounts.byId(result.accountId))!;
    expect(account.name, 'Conta principal');
    expect(account.currency, 'BRL');
    final institutions = await repos.institutions.all();
    expect(institutions.single.name, 'Minha Corretora');
  });
}
