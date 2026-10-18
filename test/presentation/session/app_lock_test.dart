import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/application/backup/backup_service.dart';
import 'package:patrion/application/portfolio/registry_service.dart';
import 'package:patrion/core/config/app_paths.dart';
import 'package:patrion/core/crypto/crypto_box.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/data/db/app_database.dart';
import 'package:patrion/data/repositories/backup_registry_repository.dart';
import 'package:patrion/data/repositories/portfolio_repositories.dart';
import 'package:patrion/domain/backup/backup_metadata.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/security/key_file.dart';
import 'package:patrion/domain/security/recovery_key.dart';
import 'package:patrion/infrastructure/backup/database_file_inspector.dart';
import 'package:patrion/infrastructure/backup/local_backup_file_system.dart';
import 'package:patrion/infrastructure/security/key_file_store.dart';
import 'package:patrion/presentation/session/app_session.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../data/db/migrations/patrion/generated/schema_v2.dart' as v2;
import '../../helpers/fake_security.dart';

/// Bloqueio do app (SPEC §3, testes obrigatórios), com banco em arquivo e o
/// SQLCipher de verdade. A derivação de chave usa parâmetros pequenos, para
/// os testes rodarem rápido; a de produção é testada em `key_file_test`.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory tmp;
  late AppPaths paths;
  late FakeHello hello;
  late MemoryHelloVault vault;
  late SessionManager manager;

  const password = 'senha-forte-1';

  SessionManager newManager() => SessionManager(
    paths: paths,
    hello: hello,
    helloVault: vault,
    beforeClose: () async {},
    kdfPolicy: KdfPolicy.fastForTests,
  );

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('patrion_lock_test_');
    paths = AppPaths(
      dataDir: p.join(tmp.path, 'dados'),
      cacheDir: p.join(tmp.path, 'cache'),
    );
    Directory(paths.dataDir).createSync(recursive: true);
    hello = FakeHello();
    vault = MemoryHelloVault();
    manager = newManager();
    await manager.start();
  });

  tearDown(() async {
    if (manager.phase == SessionPhase.ready) await manager.session.db.close();
    tmp.deleteSync(recursive: true);
  });

  RegistryService registry() => RegistryService(
    PortfolioRepositories(manager.session.db, manager.session.sync),
  );

  Future<void> addInstitution(String name) => registry().createInstitution(
    Institution(
      id: '',
      name: name,
      kind: InstitutionKind.broker,
      country: 'BR',
    ),
  );

  Future<List<String>> names() async => [
    for (final i in await PortfolioRepositories(
      manager.session.db,
      manager.session.sync,
    ).institutions.all())
      i.name,
  ];

  bool fileContains(String path, String text) =>
      String.fromCharCodes(File(path).readAsBytesSync()).contains(text);

  Future<String> enable() => manager.enableLock(password);

  test('sem bloqueio, o app abre direto e o banco não é criptografado', () {
    expect(manager.phase, SessionPhase.ready);
    expect(manager.lockEnabled, isFalse);
    expect(DatabaseFileInspector.isPlaintext(paths.databaseFile), isTrue);
  });

  group('ativar', () {
    test('banco ilegível sem a chave; os dados continuam; backup antes; '
        'chave de recuperação no formato', () async {
      await addInstitution('Corretora Secreta');
      await manager.session.db.customStatement('PRAGMA wal_checkpoint');
      expect(fileContains(paths.databaseFile, 'Corretora Secreta'), isTrue);

      final code = await enable();

      expect(manager.phase, SessionPhase.ready);
      expect(manager.lockEnabled, isTrue);
      expect(await names(), ['Corretora Secreta']);
      expect(RecoveryKey.normalize(code), isNotNull);
      expect(code, matches(RegExp(r'^([0-9A-Z]{4}-){7}[0-9A-Z]{4}$')));
      expect(manager.takePendingRecoveryKey(), code);
      expect(manager.takePendingRecoveryKey(), isNull);

      // Ilegível sem a chave: nem o SQLite abre, nem o texto aparece.
      expect(DatabaseFileInspector.isPlaintext(paths.databaseFile), isFalse);
      expect(fileContains(paths.databaseFile, 'Corretora Secreta'), isFalse);
      final raw = sqlite3.open(paths.databaseFile, mode: OpenMode.readOnly);
      expect(
        () => raw.select('SELECT count(*) FROM sqlite_master'),
        throwsA(isA<SqliteException>()),
      );
      raw.close();
      expect(
        () => DatabaseFileInspector.inspect(paths.databaseFile),
        throwsA(isA<DataError>()),
      );
      // O arquivo de chaves não tem a senha nem a chave em claro.
      final keysText = File(KeyFileStore(paths.dataDir).path)
          .readAsStringSync();
      expect(keysText, isNot(contains(password)));
      expect(
        keysText.toLowerCase(),
        isNot(contains(manager.session.key!.pragmaValue.substring(3, 67))),
      );
      // Nenhum arquivo de conversão sobrou.
      final leftovers = Directory(paths.dataDir)
          .listSync()
          .map((f) => p.basename(f.path))
          .where((n) => n.contains('.anterior') || n.contains('.convert'));
      expect(leftovers, isEmpty);
      // Backup antes de ativar, já criptografado (opção padrão).
      final rows = await BackupRegistryRepository(manager.session.db).all();
      final pre = rows.singleWhere((r) => r.reason == 'pre-bloqueio');
      expect(pre.encryption, BackupMetadata.encryptionSqlcipher);
      expect(DatabaseFileInspector.isPlaintext(pre.path), isFalse);
      expect(fileContains(pre.path, 'Corretora Secreta'), isFalse);
    });

    test('a chave de recuperação já está pendente quando a sessão nova é '
        'publicada (a tela remontada a mostra ao aparecer)', () async {
      String? seenWhenReady;
      manager.addListener(() {
        if (manager.phase == SessionPhase.ready && manager.lockEnabled) {
          seenWhenReady ??= manager.takePendingRecoveryKey();
        }
      });
      final code = await enable();
      expect(seenWhenReady, code);
    });

    test('senha fraca é recusada e nada muda', () async {
      await expectLater(manager.enableLock('curta'), throwsA(isA<DataError>()));
      expect(manager.lockEnabled, isFalse);
      expect(KeyFileStore(paths.dataDir).exists, isFalse);
    });
  });

  group('bloquear e desbloquear', () {
    setUp(() async {
      await addInstitution('Antes');
      await enable();
    });

    test('bloqueio fecha o banco e zera a chave; ao reabrir o app, pede a '
        'senha', () async {
      final session = manager.session;
      await manager.lockNow();

      expect(manager.phase, SessionPhase.locked);
      expect(
        () => session.db.customSelect('SELECT 1').get(),
        throwsA(anything),
      );
      expect(() => session.key!.bytes, throwsStateError);

      // Outro "início" do app com a mesma pasta: tela de desbloqueio.
      final again = newManager();
      await again.start();
      expect(again.phase, SessionPhase.locked);
    });

    test('senha errada é recusada e o app continua bloqueado', () async {
      await manager.lockNow();
      await expectLater(
        manager.unlockWithPassword('senha-errada'),
        throwsA(
          isA<DataError>().having((e) => e.message, 'm', 'Senha incorreta.'),
        ),
      );
      expect(manager.phase, SessionPhase.locked);

      await manager.unlockWithPassword(password);
      expect(manager.phase, SessionPhase.ready);
      expect(await names(), ['Antes']);
    });

    test(
      'troca de senha sem perda de dados: a antiga deixa de valer',
      () async {
        await addInstitution('Depois');
        await expectLater(
          manager.changePassword('errada-123', 'nova-senha-2'),
          throwsA(isA<DataError>()),
        );
        await manager.changePassword(password, 'nova-senha-2');
        await manager.lockNow();

        await expectLater(
          manager.unlockWithPassword(password),
          throwsA(isA<DataError>()),
        );
        await manager.unlockWithPassword('nova-senha-2');
        expect(await names(), ['Antes', 'Depois']);
      },
    );

    test(
      'recuperação pela chave: define nova senha e os dados voltam',
      () async {
        final code = await manager.newRecoveryKey(password);
        await manager.lockNow();

        await expectLater(
          manager.unlockWithRecoveryKey('0000-0000', 'outra-senha-3'),
          throwsA(isA<DataError>()),
        );
        expect(manager.phase, SessionPhase.locked);
        // Digitada em minúsculas, sem hífens e com O no lugar de 0: vale.
        final typed = code
            .replaceAll('-', ' ')
            .toLowerCase()
            .replaceAll('0', 'o');
        await manager.unlockWithRecoveryKey(typed, 'outra-senha-3');
        expect(manager.phase, SessionPhase.ready);
        expect(manager.notice, 'Senha redefinida.');
        expect(await names(), ['Antes']);

        await manager.lockNow();
        await expectLater(
          manager.unlockWithPassword(password),
          throwsA(isA<DataError>()),
        );
        await manager.unlockWithPassword('outra-senha-3');
        expect(manager.phase, SessionPhase.ready);
      },
    );

    test(
      'a chave de recuperação anterior deixa de valer ao gerar outra',
      () async {
        final keys = manager.keys!;
        await manager.newRecoveryKey(password);
        // O arquivo antigo (com a chave antiga) ainda abriria; o novo não.
        expect(manager.keys!.recovery.data, isNot(keys.recovery.data));
      },
    );

    test('Windows Hello: ativa, desbloqueia; recusa sem confirmação', () async {
      await manager.setHello(true);
      expect(manager.helloEnabled, isTrue);
      expect(vault.exists, isTrue);
      await manager.lockNow();

      hello.confirms = false;
      await expectLater(manager.unlockWithHello(), throwsA(isA<DataError>()));
      expect(manager.phase, SessionPhase.locked);

      hello.confirms = true;
      await manager.unlockWithHello();
      expect(manager.phase, SessionPhase.ready);
      expect(await names(), ['Antes']);

      await manager.setHello(false);
      expect(vault.exists, isFalse);
      expect(KeyFileStore(paths.dataDir).read()!.windowsHello, isFalse);
    });

    test('Windows Hello indisponível não ativa', () async {
      hello.available = false;
      await expectLater(manager.setHello(true), throwsA(isA<DataError>()));
      expect(manager.helloEnabled, isFalse);
    });
  });

  group('backups criptografados', () {
    test(
      'backup criptografado é restaurável e leva o arquivo de chaves',
      () async {
        await addInstitution('No backup');
        await enable();
        final backup = await manager.session.backupService().createManual();
        await addInstitution('Depois do backup');

        expect(backup.encryption, BackupMetadata.encryptionSqlcipher);
        expect(DatabaseFileInspector.isPlaintext(backup.path), isFalse);
        expect(fileContains(backup.path, 'No backup'), isFalse);
        final copy = const LocalBackupFileSystem().readKeyFile(backup.path);
        expect(copy!.keyId, manager.keys!.keyId);
        final meta = const LocalBackupFileSystem().readMetadata(backup.path)!;
        expect(meta.keyId, manager.keys!.keyId);

        await manager.restore(backup.path);
        expect(manager.phase, SessionPhase.ready);
        expect(await names(), ['No backup']);
        expect(DatabaseFileInspector.isPlaintext(paths.databaseFile), isFalse);
      },
    );

    test('backup sem criptografia restaurado com o bloqueio ativo fica '
        'criptografado', () async {
      await addInstitution('Aberto');
      final plain = await manager.session.backupService().createManual(
        directory: p.join(tmp.path, 'fora'),
      );
      await manager.enableLock(password, encryptBackups: false);
      expect(DatabaseFileInspector.isPlaintext(plain.path), isTrue);

      await manager.restore(plain.path);
      expect(await names(), ['Aberto']);
      expect(DatabaseFileInspector.isPlaintext(paths.databaseFile), isFalse);
    });

    test('backup de uma chave anterior pede a senha daquela época', () async {
      await addInstitution('Época 1');
      await enable();
      final old = await manager.session.backupService().createManual();
      await manager.disableLock(password);
      await manager.enableLock('senha-nova-9');
      await addInstitution('Época 2');

      expect(
        () => manager.session.backupService().checkRestore(old.path),
        throwsA(isA<BackupLockedError>()),
      );
      await expectLater(
        manager.restore(old.path),
        throwsA(isA<BackupLockedError>()),
      );
      await expectLater(
        manager.restore(old.path, backupSecret: 'senha-nova-9'),
        throwsA(isA<DataError>()),
      );
      await manager.restore(old.path, backupSecret: password);
      expect(await names(), ['Época 1']);
      // O banco fica com a chave atual.
      await manager.lockNow();
      await manager.unlockWithPassword('senha-nova-9');
      expect(await names(), ['Época 1']);
    });

    test('ativar criptografa os backups antigos da pasta de backups, que '
        'continuam restauráveis', () async {
      await addInstitution('Antigo');
      final before = await manager.session.backupService().createManual();
      expect(DatabaseFileInspector.isPlaintext(before.path), isTrue);
      await enable();

      expect(DatabaseFileInspector.isPlaintext(before.path), isFalse);
      final row = (await BackupRegistryRepository(manager.session.db)
          .byPath(before.path))!;
      expect(row.encryption, BackupMetadata.encryptionSqlcipher);
      final meta = const LocalBackupFileSystem().readMetadata(before.path)!;
      expect(meta.sha256, row.sha256);
      await addInstitution('Novo');
      await manager.restore(before.path);
      expect(await names(), ['Antigo']);
    });
  });

  test(
    'desativar volta ao banco aberto, com a senha, sem perder dados',
    () async {
      await addInstitution('Fica');
      await enable();
      await manager.setHello(true);
      await expectLater(
        manager.disableLock('senha-errada'),
        throwsA(isA<DataError>()),
      );
      expect(manager.lockEnabled, isTrue);

      await manager.disableLock(password);

      expect(manager.lockEnabled, isFalse);
      expect(manager.phase, SessionPhase.ready);
      expect(await names(), ['Fica']);
      expect(DatabaseFileInspector.isPlaintext(paths.databaseFile), isTrue);
      expect(KeyFileStore(paths.dataDir).exists, isFalse);
      expect(vault.exists, isFalse);
      final rows = await BackupRegistryRepository(manager.session.db).all();
      final pre = rows.singleWhere((r) => r.reason == 'pre-desbloqueio');
      expect(pre.encryption, BackupMetadata.encryptionSqlcipher);
    },
  );

  group('início do app', () {
    test('ativação interrompida (chaves gravadas, banco ainda aberto): as '
        'chaves são postas de lado e o app abre', () async {
      await addInstitution('Aberto');
      final created = await KeyFile.create(
        password: password,
        now: '2026-10-17T12:00:00.000Z',
        policy: KdfPolicy.fastForTests,
      );
      KeyFileStore(paths.dataDir).write(created.file);
      await manager.session.db.close();

      manager = newManager();
      await manager.start();
      expect(manager.phase, SessionPhase.ready);
      expect(manager.lockEnabled, isFalse);
      expect(await names(), ['Aberto']);
      expect(KeyFileStore(paths.dataDir).exists, isFalse);
    });

    test(
      'banco criptografado sem o arquivo de chaves: avisa e não abre',
      () async {
        await enable();
        await manager.lockNow();
        File(KeyFileStore(paths.dataDir).path).deleteSync();

        manager = newManager();
        await manager.start();
        expect(manager.phase, SessionPhase.failed);
        expect(manager.notice, contains(KeyFileStore.fileName));
      },
    );
  });

  test('migração de schema com o banco criptografado: backup criptografado '
      'antes e dados preservados', () async {
    await manager.session.db.close();
    // Banco real no schema 2, criptografado com uma chave do bloqueio.
    File(paths.databaseFile).deleteSync();
    final old = v2.DatabaseAtV2(NativeDatabase(File(paths.databaseFile)));
    await old.customStatement(
      'INSERT INTO institutions (id, created_at, updated_at, hlc, device_id, '
      'deleted_at, name, name_key, kind, country, notes) VALUES (?, ?, ?, ?, '
      '?, NULL, ?, ?, ?, ?, NULL)',
      [
        '0199f2a0-0000-7000-8000-0000000000aa',
        '2026-10-17T12:00:00.000Z',
        '2026-10-17T12:00:00.000Z',
        '001760702400000-00001-0199f2a0-0000-7000-8000-000000000001',
        '0199f2a0-0000-7000-8000-000000000001',
        'Da versão 2',
        'da versao 2',
        'broker',
        'BR',
      ],
    );
    await old.close();
    final created = await KeyFile.create(
      password: password,
      now: '2026-10-17T12:00:00.000Z',
      policy: KdfPolicy.fastForTests,
    );
    final encrypted = '${paths.databaseFile}.enc';
    DatabaseFileInspector.convert(
      source: paths.databaseFile,
      target: encrypted,
      targetKey: created.key,
    );
    File(paths.databaseFile).deleteSync();
    File(encrypted).renameSync(paths.databaseFile);
    KeyFileStore(paths.dataDir).write(created.file);
    expect(
      DatabaseFileInspector.userVersion(paths.databaseFile, key: created.key),
      2,
    );

    manager = newManager();
    await manager.start();
    expect(manager.phase, SessionPhase.locked);
    await manager.unlockWithPassword(password);

    expect(manager.session.db.schemaVersion, AppDatabase.latestSchemaVersion);
    expect(await names(), ['Da versão 2']);
    final backups = await BackupRegistryRepository(manager.session.db).all();
    final pre = backups.singleWhere((r) => r.reason == 'pre-migracao');
    expect(pre.encryption, BackupMetadata.encryptionSqlcipher);
    expect(DatabaseFileInspector.isPlaintext(pre.path), isFalse);
    expect(
      DatabaseFileInspector.userVersion(pre.path, key: manager.session.key),
      2,
    );
    expect(const LocalBackupFileSystem().readKeyFile(pre.path), isNotNull);
    expect(
      DatabaseFileInspector.userVersion(
        paths.databaseFile,
        key: manager.session.key,
      ),
      AppDatabase.latestSchemaVersion,
    );
  });
}
