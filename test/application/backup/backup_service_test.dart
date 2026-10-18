import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/application/portfolio/registry_service.dart';
import 'package:patrion/core/config/app_paths.dart';
import 'package:patrion/core/crypto/database_key.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/data/db/app_database.dart';
import 'package:patrion/data/repositories/backup_registry_repository.dart';
import 'package:patrion/data/repositories/portfolio_repositories.dart';
import 'package:patrion/data/sync/sync_tables_gateway.dart';
import 'package:patrion/domain/backup/backup_metadata.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/security/key_file.dart';
import 'package:patrion/infrastructure/backup/local_backup_file_system.dart';
import 'package:patrion/presentation/session/app_session.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../helpers/fake_security.dart';

/// Backup e restauração (SPEC §11), com banco em arquivo de verdade.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory tmp;
  late AppPaths paths;
  late AppSession session;

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('patrion_backup_service_');
    paths = AppPaths(
      dataDir: p.join(tmp.path, 'dados'),
      cacheDir: p.join(tmp.path, 'cache'),
    );
    Directory(paths.dataDir).createSync(recursive: true);
    session = await openSession(paths);
  });

  tearDown(() async {
    await session.db.close();
    tmp.deleteSync(recursive: true);
  });

  Future<String> addInstitution(AppSession s, String name) =>
      RegistryService(PortfolioRepositories(s.db, s.sync)).createInstitution(
        Institution(
          id: '',
          name: name,
          kind: InstitutionKind.broker,
          country: 'BR',
        ),
      );

  Future<List<String>> institutionNames(AppSession s) async => [
    for (final i in await PortfolioRepositories(
      s.db,
      s.sync,
    ).institutions.all())
      i.name,
  ];

  group('backup', () {
    test(
      'manual: cópia íntegra e verificada, com data, motivo, schema e '
      'versão no nome, metadados ao lado e registro em dev_backups',
      () async {
        await addInstitution(session, 'Corretora A');

        final row = await session.backupService().createManual();

        final name = p.basename(row.path);
        expect(name, startsWith('patrion_'));
        expect(
          name,
          contains('_manual_schema-v${AppDatabase.latestSchemaVersion}_'),
        );
        expect(name, endsWith('.db'));
        expect(p.dirname(row.path), paths.backupsDir);
        final bytes = File(row.path).readAsBytesSync();
        expect(row.sha256, sha256.convert(bytes).toString());
        expect(row.size, bytes.length);
        expect(row.encryption, 'none');

        final meta = BackupMetadata.fromJson(
          jsonDecode(
            File(LocalBackupFileSystem.metadataPathOf(row.path))
                .readAsStringSync(),
          ),
        );
        expect(meta.encryption, BackupMetadata.encryptionNone);
        expect(meta.sha256, row.sha256);
        expect(meta.reason, BackupReason.manual);
        expect(meta.deviceId, session.identity.deviceId);

        final copy = sqlite3.open(row.path, mode: OpenMode.readOnly);
        expect(copy.select('PRAGMA integrity_check').first.columnAt(0), 'ok');
        expect(
          copy.select('SELECT name FROM institutions').single['name'],
          'Corretora A',
        );
        copy.close();
        expect(
          (await BackupRegistryRepository(session.db).all()).single.path,
          row.path,
        );
      },
    );

    test('manual em outra pasta', () async {
      final other = p.join(tmp.path, 'pendrive');
      final row = await session.backupService().createManual(directory: other);
      expect(p.dirname(row.path), other);
      expect(File(row.path).existsSync(), isTrue);
    });

    test('retenção: só os mais recentes de cada motivo automático; manuais '
        'ficam', () async {
      final manual = await session.backupService().createManual();
      final service = session.backupService(keepAutomatic: 3);
      for (var i = 0; i < 5; i++) {
        await service.createAutomatic(BackupReason.preImport);
      }
      final files = Directory(paths.backupsDir)
          .listSync()
          .map((f) => p.basename(f.path))
          .where((n) => n.endsWith('.db'))
          .toList();
      expect(files.where((n) => n.contains('_pre-importacao_')), hasLength(3));
      expect(File(manual.path).existsSync(), isTrue);
      final rows = await BackupRegistryRepository(session.db).all();
      expect(rows.where((r) => r.reason == 'pre-importacao'), hasLength(3));
      expect(rows.where((r) => r.reason == 'manual'), hasLength(1));
    });
  });

  group('conferência antes de restaurar', () {
    test('recusa arquivo inexistente, que não é banco, de schema mais novo, '
        'alterado depois do backup ou com a criptografia diferente da dos '
        'metadados', () async {
      final service = session.backupService();
      expect(
        () => service.checkRestore(p.join(tmp.path, 'nao-existe.db')),
        throwsA(isA<DataError>()),
      );

      final text = File(p.join(tmp.path, 'texto.db'))
        ..writeAsStringSync('não sou um banco');
      expect(() => service.checkRestore(text.path), throwsA(isA<DataError>()));

      final good = await service.createManual();
      expect(service.checkRestore(good.path).info.integrityOk, isTrue);

      final newer = await service.createManual();
      final db = sqlite3.open(newer.path)..execute('PRAGMA user_version = 99');
      db.close();
      expect(
        () => service.checkRestore(newer.path),
        throwsA(
          isA<DataError>().having((e) => e.message, 'm', contains('nova')),
        ),
      );

      final tampered = await service.createManual();
      final metaFile = File(
        LocalBackupFileSystem.metadataPathOf(tampered.path),
      );
      final json =
          jsonDecode(metaFile.readAsStringSync()) as Map<String, Object?>;
      metaFile.writeAsStringSync(jsonEncode({...json, 'sha256': '0' * 64}));
      expect(
        () => service.checkRestore(tampered.path),
        throwsA(
          isA<DataError>().having((e) => e.message, 'm', contains('SHA-256')),
        ),
      );

      final encrypted = await service.createManual();
      final encMeta = File(
        LocalBackupFileSystem.metadataPathOf(encrypted.path),
      );
      final encJson =
          jsonDecode(encMeta.readAsStringSync()) as Map<String, Object?>;
      encMeta.writeAsStringSync(
        jsonEncode({
          ...encJson,
          'encryption': {'scheme': 'sqlcipher-4'},
        }),
      );
      expect(
        () => service.checkRestore(encrypted.path),
        throwsA(
          isA<DataError>().having(
            (e) => e.message,
            'm',
            contains('criptografia'),
          ),
        ),
      );
    });
  });

  group('restauração', () {
    test('substitui os dados pelos do backup, faz backup do estado atual antes '
        'e mantém a identidade e o HLC deste PC', () async {
      await addInstitution(session, 'Antes do backup');
      final backup = await session.backupService().createManual();
      await addInstitution(session, 'Depois do backup');
      final deviceId = session.identity.deviceId;
      final hlcBefore = session.sync.lastHlc;

      final manager = SessionManager(
        paths: session.paths,
        session: session,
        hello: FakeHello(),
        helloVault: MemoryHelloVault(),
        beforeClose: () async {},
      );
      await manager.restore(backup.path);
      session = manager.session;

      expect(await institutionNames(session), ['Antes do backup']);
      expect(session.identity.deviceId, deviceId);
      expect(
        session.sync.lastHlc.compareTo(hlcBefore),
        greaterThanOrEqualTo(0),
      );
      expect(manager.generation, 1);
      expect(manager.notice, contains('restaurado'));

      final rows = await BackupRegistryRepository(session.db).all();
      final preRestore = rows.where((r) => r.reason == 'pre-restauracao');
      expect(preRestore, hasLength(1));
      expect(rows.where((r) => r.reason == 'manual'), hasLength(1));
      // O backup do estado anterior tem o dado que o restaurado não tem.
      final copy = sqlite3.open(
        preRestore.single.path,
        mode: OpenMode.readOnly,
      );
      expect(copy.select('SELECT name FROM institutions'), hasLength(2));
      copy.close();

      // Uma alteração depois de restaurar tem HLC maior que tudo o que este
      // PC já tinha emitido (e talvez exportado).
      await addInstitution(session, 'Depois de restaurar');
      final latest = session.sync.lastHlc;
      expect(latest > hlcBefore, isTrue);
    });

    test(
      'backup de outro PC: os dados vêm, a identidade deste PC fica',
      () async {
        final otherDir = p.join(tmp.path, 'outro');
        Directory(otherDir).createSync();
        final other = await openSession(
          AppPaths(dataDir: otherDir, cacheDir: p.join(tmp.path, 'c2')),
        );
        await addInstitution(other, 'Do outro PC');
        final otherBackup = await other.backupService().createManual();
        final otherDevice = other.identity.deviceId;
        await other.db.close();
        final deviceId = session.identity.deviceId;

        final manager = SessionManager(
          paths: session.paths,
          session: session,
          hello: FakeHello(),
          helloVault: MemoryHelloVault(),
          beforeClose: () async {},
        );
        await manager.restore(otherBackup.path);
        session = manager.session;

        expect(await institutionNames(session), ['Do outro PC']);
        expect(session.identity.deviceId, deviceId);
        expect(session.identity.deviceId, isNot(otherDevice));
        final identities = await session.db
            .select(session.db.devIdentity)
            .get();
        expect(identities.single.deviceId, deviceId);
      },
    );

    test('falha ao reabrir no meio da restauração: o banco anterior volta '
        'intacto e o app continua aberto', () async {
      await addInstitution(session, 'Antes do backup');
      final backup = await session.backupService().createManual();
      await addInstitution(session, 'Depois do backup');
      final gateway = SyncTablesGateway(session.db, session.sync);
      final before = await gateway.readAll(await gateway.schemas());
      final deviceId = session.identity.deviceId;
      final hlcBefore = session.sync.lastHlc;

      var attempts = 0;
      String? swappedIn;
      Future<AppSession> failingOnce(
        AppPaths paths, {
        SessionCarryOver? carry,
        Clock wallClock = const Clock(),
        DatabaseKey? key,
        KeyFile? keys,
      }) async {
        attempts++;
        if (attempts == 1) {
          // O arquivo do backup já está no lugar do banco quando a reabertura
          // falha.
          final db = sqlite3.open(paths.databaseFile, mode: OpenMode.readOnly);
          swappedIn = db
              .select('SELECT name FROM institutions')
              .map((r) => r['name'] as String)
              .join(',');
          db.close();
          throw const DataError('falha simulada ao reabrir');
        }
        return openSession(
          paths,
          carry: carry,
          wallClock: wallClock,
          key: key,
          keys: keys,
        );
      }

      final manager = SessionManager(
        paths: session.paths,
        session: session,
        hello: FakeHello(),
        helloVault: MemoryHelloVault(),
        beforeClose: () async {},
        opener: failingOnce,
      );
      await manager.restore(backup.path);
      session = manager.session;

      expect(attempts, 2);
      expect(swappedIn, 'Antes do backup');
      expect(manager.phase, SessionPhase.ready);
      expect(manager.generation, 1);
      expect(manager.notice, contains('voltaram ao estado anterior'));
      expect(manager.notice, contains('falha simulada ao reabrir'));

      // Mesmos registros, campo a campo (inclusive HLCs), e banco íntegro.
      final after = SyncTablesGateway(session.db, session.sync);
      expect(await after.readAll(await after.schemas()), before);
      expect(await institutionNames(session), [
        'Antes do backup',
        'Depois do backup',
      ]);
      final integrity = await session.db
          .customSelect('PRAGMA integrity_check')
          .getSingle();
      expect(integrity.data.values.single, 'ok');
      expect(session.identity.deviceId, deviceId);
      expect(session.sync.lastHlc.compareTo(hlcBefore), 0);
      // O backup restaurado e o do estado anterior continuam registrados.
      final reasons = [
        for (final r in await BackupRegistryRepository(session.db).all())
          r.reason,
      ]..sort();
      expect(reasons, ['manual', 'pre-restauracao']);
      // Nenhum arquivo temporário da troca sobrou.
      expect(
        Directory(paths.dataDir).listSync().map((f) => p.basename(f.path)),
        isNot(contains(endsWith('.restaurando'))),
      );
    });

    test('arquivo recusado na conferência: nada muda', () async {
      await addInstitution(session, 'Atual');
      final text = File(p.join(tmp.path, 'ruim.db'))..writeAsStringSync('x');
      final manager = SessionManager(
        paths: session.paths,
        session: session,
        hello: FakeHello(),
        helloVault: MemoryHelloVault(),
        beforeClose: () async {},
      );

      await expectLater(manager.restore(text.path), throwsA(isA<DataError>()));

      expect(manager.generation, 0);
      expect(await institutionNames(session), ['Atual']);
      expect(await BackupRegistryRepository(session.db).all(), isEmpty);
    });
  });
}
