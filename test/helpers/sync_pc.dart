import 'dart:io';
import 'dart:typed_data';

import 'package:patrion/application/backup/backup_service.dart';
import 'package:patrion/application/portfolio/operation_service.dart';
import 'package:patrion/application/portfolio/portfolio_query.dart';
import 'package:patrion/application/portfolio/registry_service.dart';
import 'package:patrion/application/sync/save_service.dart';
import 'package:patrion/core/crypto/crypto_box.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/backup_registry_repository.dart';
import 'package:patrion/data/repositories/portfolio_repositories.dart';
import 'package:patrion/data/repositories/sync_peers_repository.dart';
import 'package:patrion/data/sync/market_save_gateway.dart';
import 'package:patrion/data/sync/sync_tables_gateway.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/sync/merge_planner.dart';
import 'package:patrion/domain/sync/sync_rows.dart';
import 'package:patrion/infrastructure/backup/local_backup_file_system.dart';
import 'package:path/path.dart' as p;

import 'portfolio_fixture.dart';
import 'test_database.dart';

/// Um "computador" para os testes de sincronização: banco em memória próprio,
/// relógio próprio, pasta de backups própria e os serviços do app.
class SyncPc {
  SyncPc._(this.name, this.t, this.backupsDir)
    : repos = PortfolioRepositories(t.db, t.sync),
      gateway = SyncTablesGateway(t.db, t.sync),
      peers = SyncPeersRepository(t.db) {
    registry = RegistryService(repos, wallClock: t.wall.clock);
    operations = OperationService(repos);
    query = PortfolioQuery(repos, wallClock: t.wall.clock);
    backups = BackupService(
      registry: BackupRegistryRepository(t.db),
      files: const LocalBackupFileSystem(),
      backupsDir: backupsDir,
      appVersion: '0.1.0',
      deviceId: t.identity.deviceId,
      deviceName: name,
      wallClock: t.wall.clock,
    );
    save = SaveService(
      tables: gateway,
      peers: peers,
      sync: t.sync,
      backups: backups,
      appVersion: '0.1.0',
      deviceName: name,
      wallClock: t.wall.clock,
      portfolio: query,
      market: MarketSaveGateway(t.db),
      kdfPolicy: KdfPolicy.fastForTests,
      beforeWrite: (i) {
        if (failAtWrite != null && i == failAtWrite) {
          throw StateError('falha simulada na escrita $i');
        }
      },
    );
  }

  static Future<SyncPc> open(
    String name,
    Directory tmp, {
    DateTime? start,
  }) async {
    final t = await TestDb.open(deviceName: name, start: start);
    return SyncPc._(name, t, p.join(tmp.path, name, 'backups'));
  }

  final String name;
  final TestDb t;
  final String backupsDir;
  final PortfolioRepositories repos;
  final SyncTablesGateway gateway;
  final SyncPeersRepository peers;
  late final RegistryService registry;
  late final OperationService operations;
  late final PortfolioQuery query;
  late final BackupService backups;
  late final SaveService save;

  /// Índice da escrita em que a próxima importação falha (S9).
  int? failAtWrite;

  String get deviceId => t.identity.deviceId;

  /// Avança o relógio deste PC (cada ação acontece "depois").
  void tick([Duration d = const Duration(minutes: 1)]) => t.wall.advance(d);

  Future<Uint8List> export({String? password}) async {
    tick();
    final e = await save.buildExport(password: password);
    await save.recordExport(e, e.suggestedFileName);
    return e.bytes;
  }

  Future<ImportPreview> preview(Uint8List bytes, {String? password}) async {
    tick();
    return save.preview(bytes, fileName: 'teste.invsave', password: password);
  }

  Future<MergePlan> import(
    Uint8List bytes, {
    Map<RowRef, MergeSide> resolutions = const {},
  }) async {
    final pre = await preview(bytes);
    return (await save.apply(pre, resolutions: resolutions)).plan;
  }

  /// Todas as tabelas sincronizáveis, inclusive tombstones.
  Future<Map<String, List<SyncRow>>> dump() async =>
      gateway.readAll(await gateway.schemas());

  Future<SyncRow?> row(String table, String id) async {
    final rows = (await dump())[table]!;
    for (final r in rows) {
      if (r.id == id) return r;
    }
    return null;
  }

  // -- Cadastros e operações ---------------------------------------------------

  Future<String> institution(String name) {
    tick();
    return registry.createInstitution(
      Institution(
        id: '',
        name: name,
        kind: InstitutionKind.broker,
        country: 'BR',
      ),
    );
  }

  Future<String> account(String institutionId, String name) {
    tick();
    return registry.createAccount(
      Account(
        id: '',
        institutionId: institutionId,
        name: name,
        kind: AccountKind.brokerage,
        currency: 'BRL',
      ),
    );
  }

  Future<String> stock(String symbol) {
    tick();
    return registry.createAsset(
      Asset(
        id: '',
        symbol: symbol,
        market: Market.b3,
        assetClass: AssetClass.stockBr,
        name: symbol,
        currency: 'BRL',
        country: 'BR',
      ),
    );
  }

  OperationDraft buyDraft(
    String account,
    String asset,
    String qty, {
    String price = '10',
    String date = '2026-01-05',
    OperationType type = OperationType.buy,
  }) => OperationDraft(
    accountId: account,
    assetId: asset,
    type: type,
    tradeDate: LocalDate.parse(date),
    currency: 'BRL',
    quantity: dec(qty),
    unitPrice: dec(price),
    fees: dec('0'),
  );

  Future<String> sell(
    String account,
    String asset,
    String qty, {
    String price = '12',
    String date = '2026-02-10',
  }) async {
    tick();
    final outcome = await operations.save(
      buyDraft(
        account,
        asset,
        qty,
        price: price,
        date: date,
        type: OperationType.sell,
      ),
      allowDuplicate: true,
    );
    return (outcome as Saved).id;
  }

  Future<String> buy(
    String account,
    String asset,
    String qty, {
    String price = '10',
    String date = '2026-01-05',
  }) async {
    tick();
    final outcome = await operations.save(
      buyDraft(account, asset, qty, price: price, date: date),
      allowDuplicate: true,
    );
    return (outcome as Saved).id;
  }

  Future<void> editBuy(
    String id,
    String account,
    String asset,
    String qty, {
    String price = '10',
    String date = '2026-01-05',
  }) async {
    tick();
    await operations.save(
      buyDraft(account, asset, qty, price: price, date: date),
      id: id,
    );
  }

  Future<void> close() => t.close();
}

/// A exporta e B importa; depois B exporta e A importa (SPEC §10.5).
Future<void> syncBoth(SyncPc a, SyncPc b) async {
  await b.import(await a.export());
  await a.import(await b.export());
}
