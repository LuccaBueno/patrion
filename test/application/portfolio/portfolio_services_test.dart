import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/application/portfolio/operation_service.dart';
import 'package:patrion/application/portfolio/portfolio_query.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/core/sync/hlc.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/portfolio_repositories.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/portfolio/operation_validator.dart';

import '../../helpers/portfolio_fixture.dart';
import '../../helpers/test_database.dart';

void main() {
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() => f.t.close());

  group('cadastros', () {
    test('instituição com o mesmo nome (sem acento/caixa) é recusada', () {
      expect(
        () => f.registry.createInstitution(
          const Institution(
            id: '',
            name: '  corretora   EXEMPLO ',
            kind: InstitutionKind.broker,
            country: 'BR',
          ),
        ),
        throwsA(isA<DataError>()),
      );
    });

    test('ativo com a mesma chave natural é recusado', () {
      expect(
        () => f.registry.createAsset(
          const Asset(
            id: '',
            symbol: 'petr4',
            market: Market.b3,
            assetClass: AssetClass.stockBr,
            name: 'Outra',
            currency: 'BRL',
            country: 'BR',
          ),
        ),
        throwsA(isA<DataError>()),
      );
    });

    test('renda fixa exige características, e elas são gravadas', () async {
      expect(
        () => f.registry.createAsset(
          const Asset(
            id: '',
            symbol: 'LCI-X',
            market: Market.manual,
            assetClass: AssetClass.fixedIncome,
            name: 'LCI',
            currency: 'BRL',
            country: 'BR',
          ),
        ),
        throwsA(isA<DataError>()),
      );
      final terms = await f.repos.fixedIncome.forAsset(f.cdb);
      expect(terms!.rate, dec('110'));
      expect(terms.maturityDate, LocalDate(2026, 12, 1));
    });

    test('cadastros em uso não podem ser excluídos', () async {
      await f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '1', price: '1'),
      );
      expect(() => f.registry.deleteAsset(f.petr), throwsA(isA<DataError>()));
      expect(
        () => f.registry.deleteAccount(f.account),
        throwsA(isA<DataError>()),
      );
      expect(
        () => f.registry.deleteInstitution(f.broker),
        throwsA(isA<DataError>()),
      );
    });

    test('excluir é lógico (tombstone) e some das listas', () async {
      await f.registry.deleteAccount(f.account2);
      expect((await f.repos.accounts.all()).map((a) => a.id), [f.account]);
      final row = await f.repos.accounts.findRowById(
        f.account2,
        includeDeleted: true,
      );
      expect(row!.deletedAt, isNotNull);
    });

    test(
      'arquivar conta grava archived_at e preserva no desarquivar',
      () async {
        final acc = (await f.repos.accounts.byId(f.account2))!;
        await f.registry.updateAccount(
          Account(
            id: acc.id,
            institutionId: acc.institutionId,
            name: acc.name,
            kind: acc.kind,
            currency: acc.currency,
            archived: true,
          ),
        );
        expect((await f.repos.accounts.byId(f.account2))!.archived, isTrue);
        expect(await f.repos.accounts.archivedAt(f.account2), isNotNull);
      },
    );
  });

  group('operações', () {
    test('grava com campos de sincronização preenchidos', () async {
      final id = await f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '100', price: '30'),
      );
      final row = (await f.repos.operations.findRowById(id))!;
      expect(row.deviceId, f.t.identity.deviceId);
      expect(Hlc.parse(row.hlc).deviceId, f.t.identity.deviceId);
      expect(row.type, 'buy');
      expect(row.quantity, dec('100'));
      expect(row.origin, 'manual');
    });

    test('problemas de preenchimento lançam ValidationFailure', () {
      expect(
        () => f.operations.save(f.draft(OperationType.buy, '2024-01-10')),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('moeda diferente da do ativo é recusada', () {
      final d = f.draft(OperationType.buy, '2024-01-10', qty: '1', price: '1');
      expect(
        () => f.operations.save(
          OperationDraft(
            accountId: d.accountId,
            assetId: d.assetId,
            type: d.type,
            tradeDate: d.tradeDate,
            currency: 'USD',
            quantity: d.quantity,
            unitPrice: d.unitPrice,
          ),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('duplicata é detectada e só grava com confirmação', () async {
      final d = f.draft(
        OperationType.buy,
        '2024-01-10',
        qty: '100',
        price: '30',
      );
      expect(await f.operations.save(d), isA<Saved>());
      final second = await f.operations.save(d);
      expect(second, isA<PossibleDuplicate>());
      expect((second as PossibleDuplicate).matches, hasLength(1));
      expect(await f.repos.operations.all(), hasLength(1));

      expect(await f.operations.save(d, allowDuplicate: true), isA<Saved>());
      expect(await f.repos.operations.all(), hasLength(2));
    });

    test('venda maior que a posição é recusada', () async {
      await f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '10', price: '30'),
      );
      expect(
        () => f.operations.save(
          f.draft(OperationType.sell, '2024-01-11', qty: '11', price: '30'),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('editar ou excluir uma compra antiga que deixaria venda a '
        'descoberto é recusado', () async {
      final buy = await f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '10', price: '30'),
      );
      await f.add(
        f.draft(OperationType.sell, '2024-02-10', qty: '8', price: '35'),
      );

      expect(
        () => f.operations.save(
          f.draft(OperationType.buy, '2024-01-10', qty: '5', price: '30'),
          id: buy,
        ),
        throwsA(isA<ValidationFailure>()),
      );
      expect(() => f.operations.delete(buy), throwsA(isA<ValidationFailure>()));
    });

    test('editar a operação 1 recalcula as seguintes (CASOS §1)', () async {
      final op1 = await f.add(
        f.draft(
          OperationType.buy,
          '2024-01-10',
          qty: '100',
          price: '30',
          fees: '5',
        ),
      );
      await f.add(
        f.draft(
          OperationType.buy,
          '2024-02-10',
          qty: '50',
          price: '36',
          fees: '4',
        ),
      );
      await f.add(
        f.draft(
          OperationType.sell,
          '2024-03-10',
          qty: '60',
          price: '40',
          fees: '6',
        ),
      );
      var pos = (await f.query.load()).state.position(f.account, f.petr)!;
      expect(pos.realizedPnl, dec('470.4'));

      await f.operations.save(
        f.draft(
          OperationType.buy,
          '2024-01-10',
          qty: '200',
          price: '30',
          fees: '5',
        ),
        id: op1,
      );
      pos = (await f.query.load()).state.position(f.account, f.petr)!;
      expect(pos.quantity, dec('190'));
      expect(pos.realizedPnl, dec('519.84'));
      expect(await f.repos.operations.all(), hasLength(3));
    });

    test('transferência cria, edita e exclui as duas pontas', () async {
      await f.add(
        f.draft(
          OperationType.buy,
          '2024-01-10',
          qty: '100',
          price: '30',
          fees: '5',
        ),
      );
      final group = await f.operations.saveTransfer(
        TransferInput(
          fromAccountId: f.account,
          toAccountId: f.account2,
          date: LocalDate(2024, 2, 1),
          currency: 'BRL',
          assetId: f.petr,
          quantity: dec('40'),
        ),
      );
      var snap = await f.query.load();
      expect(snap.state.position(f.account2, f.petr)!.totalCost, dec('1202'));
      expect(snap.state.issues, isEmpty);

      await f.operations.saveTransfer(
        TransferInput(
          fromAccountId: f.account,
          toAccountId: f.account2,
          date: LocalDate(2024, 2, 1),
          currency: 'BRL',
          assetId: f.petr,
          quantity: dec('50'),
        ),
        groupId: group,
      );
      snap = await f.query.load();
      expect(snap.state.position(f.account2, f.petr)!.quantity, dec('50'));
      expect(await f.repos.operations.ofTransferGroup(group), hasLength(2));

      expect(
        () => f.operations.saveTransfer(
          TransferInput(
            fromAccountId: f.account,
            toAccountId: f.account2,
            date: LocalDate(2024, 2, 1),
            currency: 'BRL',
            assetId: f.petr,
            quantity: dec('500'),
          ),
          groupId: group,
        ),
        throwsA(isA<ValidationFailure>()),
      );

      final leg = (await f.repos.operations.ofTransferGroup(group)).first;
      await f.operations.delete(leg.id);
      expect(await f.repos.operations.ofTransferGroup(group), isEmpty);
      expect(await f.repos.operations.all(), hasLength(1));
    });

    test('transferência para a mesma conta é recusada', () {
      expect(
        () => f.operations.saveTransfer(
          TransferInput(
            fromAccountId: f.account,
            toAccountId: f.account,
            date: LocalDate(2024, 2, 1),
            currency: 'BRL',
            amount: dec('10'),
          ),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('transferência não pode ser gravada pela tela comum', () {
      expect(
        () => f.operations.save(
          f.draft(
            OperationType.transferOut,
            '2024-01-10',
            asset: null,
            gross: '1',
          ),
        ),
        throwsA(isA<DataError>()),
      );
    });
  });

  group('preço manual e retrato da carteira', () {
    test('informar o preço de novo na mesma data substitui', () async {
      final id1 = await f.valuations.setUnitPrice(
        assetId: f.petr,
        refDate: LocalDate(2024, 3, 1),
        price: dec('35'),
      );
      final id2 = await f.valuations.setUnitPrice(
        assetId: f.petr,
        refDate: LocalDate(2024, 3, 1),
        price: dec('36'),
      );
      expect(id2, id1);
      final all = await f.repos.valuations.all();
      expect(all.single.value, dec('36'));
      expect(all.single.currency, 'BRL');
    });

    test('o retrato aplica preço e saldo às posições', () async {
      f.t.wall.now = DateTime(2024, 6, 1, 12);
      await f.add(
        f.draft(
          OperationType.deposit,
          '2024-01-02',
          asset: null,
          gross: '10000',
        ),
      );
      await f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '100', price: '30'),
      );
      await f.add(
        f.draft(
          OperationType.contribution,
          '2024-01-10',
          asset: f.cdb,
          gross: '2000',
        ),
      );
      await f.valuations.setUnitPrice(
        assetId: f.petr,
        refDate: LocalDate(2024, 5, 31),
        price: dec('35'),
      );
      await f.valuations.setBalance(
        assetId: f.cdb,
        accountId: f.account,
        refDate: LocalDate(2024, 5, 31),
        balance: dec('2100'),
      );

      final snap = await f.query.load();
      final brl = snap.summary.byCurrency['BRL']!;
      expect(brl.invested, dec('5000'));
      expect(brl.marketValue, dec('5600'));
      expect(brl.cash, dec('5000'));
      expect(brl.equity, dec('10600'));
      expect(snap.summary.lastValuationDate, LocalDate(2024, 5, 31));
      expect(snap.accountLabel(f.account), 'Corretora Exemplo · Principal');
    });

    test('watch emite um novo retrato a cada alteração', () async {
      final stream = f.query.watch();
      final emitted = <int>[];
      final sub = stream.listen((s) => emitted.add(s.operations.length));
      await pumpEventQueue();
      await f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '1', price: '1'),
      );
      await pumpEventQueue(times: 50);
      await sub.cancel();
      expect(emitted.first, 0);
      expect(emitted.last, 1);
    });
  });

  test('os dados persistem depois de fechar e reabrir o banco', () async {
    final tmp = Directory.systemTemp.createTempSync('patrion_persist_');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final file = File(p.join(tmp.path, 'patrion.db'));

    final first = await PortfolioFixture.open(
      db: await TestDb.open(executor: NativeDatabase(file)),
    );
    await first.add(
      first.draft(
        OperationType.buy,
        '2024-01-10',
        qty: '100',
        price: '30',
        fees: '5',
      ),
    );
    await first.valuations.setUnitPrice(
      assetId: first.petr,
      refDate: LocalDate(2024, 3, 1),
      price: dec('35'),
    );
    final deviceId = first.t.identity.deviceId;
    await first.t.close();

    final reopened = await TestDb.open(executor: NativeDatabase(file));
    addTearDown(reopened.close);
    expect(reopened.identity.deviceId, deviceId);
    final again = await PortfolioQuery(
      PortfolioRepositories(reopened.db, reopened.sync),
    ).load();
    expect(again.institutions.values.single.name, 'Corretora Exemplo');
    expect(again.accounts, hasLength(2));
    expect(again.assets, hasLength(2));
    expect(again.fixedIncome.values.single.rate, dec('110'));
    final pos = again.state.position(first.account, first.petr)!;
    expect(pos.averagePrice, dec('30.05'));
    expect(again.valuations.single.value, dec('35'));
  });
}
