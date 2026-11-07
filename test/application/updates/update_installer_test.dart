import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/updates/update_checker.dart';
import 'package:patrion/application/updates/update_installer.dart';
import 'package:patrion/data/repositories/device_settings_repository.dart';
import 'package:patrion/infrastructure/updates/minisign.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import '../../../tool/signing/bin/signing.dart';
import '../../helpers/test_database.dart';

const _base = 'https://github.com/dono/patrion/releases/download/v2.0.0';
const _name = 'Patrion-2.0.0-instalador.exe';

/// Release de mentira: o que estiver em [files], por URL.
class _Release implements UpdateDownloads {
  final files = <String, List<int>>{};
  final requested = <String>[];
  UpdateFailure? downloadError;

  /// Grava parte do arquivo antes de falhar, como uma conexão que cai.
  List<int> partial = const [];

  @override
  Future<Uint8List?> fetch(Uri uri) async {
    requested.add(uri.toString());
    final f = files[uri.toString()];
    return f == null ? null : Uint8List.fromList(f);
  }

  @override
  Future<void> download(
    Uri uri,
    String target, {
    void Function(int received, int? total)? onProgress,
    UpdateCancel? cancel,
  }) async {
    requested.add(uri.toString());
    final error = downloadError;
    if (error != null) {
      File(target).writeAsBytesSync(partial);
      throw error;
    }
    final f = files[uri.toString()]!;
    File(target).writeAsBytesSync(f);
    onProgress?.call(f.length, f.length);
  }
}

ReleaseInfo _info(String version, {String? tag}) => ReleaseInfo(
  version: Version.parse(version),
  tag: tag ?? 'v$version',
  name: 'Patrion $version',
  notes: 'Novidades da $version',
  page: Uri.parse('https://github.com/dono/patrion/releases/tag/v$version'),
  prerelease: false,
);

void main() {
  final key = SigningKey([1, 2, 3, 4, 5, 6, 7, 8], List.filled(32, 9));
  final impostor = SigningKey([1, 2, 3, 4, 5, 6, 7, 8], List.filled(32, 3));
  final exe = utf8.encode('instalador verdadeiro');
  late String public;
  late TestDb t;
  late Directory dir;
  late _Release release;
  late DeviceSettingsRepository settings;
  late List<String> events;
  late List<List<String>> started;
  Object? startError;
  Object? backupError;

  String cache() => p.join(dir.path, 'cache');
  String updates() => p.join(cache(), 'updates');

  UpdateInstaller installer({String current = '1.0.0'}) => UpdateInstaller(
    downloads: release,
    checkSignature: (message, signature) => Minisign.verify(
      message: message,
      signatureFile: signature,
      publicKeys: [public],
    ),
    settings: settings,
    current: Version.parse(current),
    startInstaller: (path, arguments) async {
      if (startError != null) throw startError!;
      events.add('instalador');
      started.add([path, ...arguments]);
    },
    backup: () async {
      if (backupError != null) throw backupError!;
      events.add('backup');
    },
    repository: 'dono/patrion',
    cacheDir: cache(),
    logsDir: p.join(dir.path, 'logs'),
    relaunchArguments: const [r'/RELAUNCH=C:\app\patrion.exe'],
    clock: Clock.fixed(DateTime.utc(2026, 11, 6, 12)),
  );

  Future<void> publish({
    List<int>? sums,
    SigningKey? signer,
    List<int>? installerBytes,
  }) async {
    final body =
        sums ??
        utf8.encode(
          '${sha256.convert(exe)}  $_name\n'
          '${sha256.convert([1])}  Patrion-2.0.0-portatil.zip\n',
        );
    release.files['$_base/SHA256SUMS.txt'] = body;
    release.files['$_base/SHA256SUMS.txt.minisig'] = utf8.encode(
      await (signer ?? key).sign(body, comment: 'patrion 2.0.0'),
    );
    release.files['$_base/$_name'] = installerBytes ?? exe;
  }

  setUp(() async {
    public = await key.publicKey();
    t = await TestDb.open();
    dir = Directory.systemTemp.createTempSync('patrion_up');
    release = _Release();
    settings = DeviceSettingsRepository(t.db);
    events = [];
    started = [];
    startError = null;
    backupError = null;
  });

  tearDown(() async {
    await t.close();
    dir.deleteSync(recursive: true);
  });

  Matcher failsWith(UpdateFailureKind kind) =>
      throwsA(isA<UpdateFailure>().having((e) => e.kind, 'kind', kind));

  void expectNothingLeft() {
    final d = Directory(updates());
    expect(d.existsSync() ? d.listSync() : const <FileSystemEntity>[], isEmpty);
  }

  group('prepare', () {
    test('confere assinatura e hash e deixa o instalador pronto', () async {
      await publish();
      final u = await installer().prepare(_info('2.0.0'));
      expect(p.basename(u.installer), _name);
      expect(File(u.installer).readAsBytesSync(), exe);
      expect(u.sha256, sha256.convert(exe).toString());
      // Só o repositório configurado, e a assinatura antes do instalador.
      expect(release.requested, [
        '$_base/SHA256SUMS.txt',
        '$_base/SHA256SUMS.txt.minisig',
        '$_base/$_name',
      ]);
    });

    test('assinatura inválida: nem baixa o instalador', () async {
      await publish(signer: impostor);
      await expectLater(
        installer().prepare(_info('2.0.0')),
        failsWith(UpdateFailureKind.badSignature),
      );
      expect(release.requested, isNot(contains('$_base/$_name')));
      expectNothingLeft();
    });

    test('somas trocadas depois de assinadas são recusadas', () async {
      await publish();
      release.files['$_base/SHA256SUMS.txt'] = utf8.encode(
        '${sha256.convert([0])}  $_name\n',
      );
      await expectLater(
        installer().prepare(_info('2.0.0')),
        failsWith(UpdateFailureKind.badSignature),
      );
    });

    test('instalador com um byte alterado é apagado', () async {
      await publish(installerBytes: [...exe]..[0] ^= 1);
      await expectLater(
        installer().prepare(_info('2.0.0')),
        failsWith(UpdateFailureKind.badHash),
      );
      expectNothingLeft();
    });

    test('Release sem assinatura (versões antigas) não instala', () async {
      await publish();
      release.files.remove('$_base/SHA256SUMS.txt.minisig');
      await expectLater(
        installer().prepare(_info('2.0.0')),
        failsWith(UpdateFailureKind.notSigned),
      );
    });

    test('assinatura válida de outra versão não serve', () async {
      await publish(
        sums: utf8.encode(
          '${sha256.convert(exe)}  Patrion-1.9.0-instalador.exe\n',
        ),
      );
      await expectLater(
        installer().prepare(_info('2.0.0')),
        failsWith(UpdateFailureKind.badSignature),
      );
      expect(release.requested, isNot(contains('$_base/$_name')));
    });

    test('versão igual ou menor que a instalada é recusada', () async {
      await publish();
      for (final current in ['2.0.0', '2.0.1']) {
        await expectLater(
          installer(current: current).prepare(_info('2.0.0')),
          failsWith(UpdateFailureKind.unavailable),
        );
      }
      expect(release.requested, isEmpty);
    });

    test('tag que não bate com a versão é recusada', () async {
      await publish();
      await expectLater(
        installer().prepare(_info('2.0.0', tag: 'v1.0.0-x')),
        failsWith(UpdateFailureKind.unavailable),
      );
      expect(release.requested, isEmpty);
    });

    test('download interrompido não deixa arquivo nenhum', () async {
      await publish();
      release
        ..partial = [1, 2, 3]
        ..downloadError = const UpdateFailure(
          UpdateFailureKind.interrupted,
          'interrompido',
        );
      await expectLater(
        installer().prepare(_info('2.0.0')),
        failsWith(UpdateFailureKind.interrupted),
      );
      expectNothingLeft();
    });

    test('sem internet: nada muda e a próxima tentativa funciona', () async {
      await publish();
      release.downloadError = const UpdateFailure(
        UpdateFailureKind.offline,
        'sem internet',
      );
      await expectLater(
        installer().prepare(_info('2.0.0')),
        failsWith(UpdateFailureKind.offline),
      );
      expect(await settings.get(UpdateInstaller.pendingKey), isNull);
      release.downloadError = null;
      await installer().prepare(_info('2.0.0'));
    });

    test('sobras de um download antigo são apagadas', () async {
      await publish();
      Directory(updates()).createSync(recursive: true);
      final old = File(p.join(updates(), 'Patrion-1.9.0-instalador.exe'))
        ..writeAsStringSync('velho');
      await installer().prepare(_info('2.0.0'));
      expect(old.existsSync(), isFalse);
    });
  });

  group('install', () {
    test('backup antes do instalador, com o pedido gravado', () async {
      await publish();
      final i = installer();
      final u = await i.prepare(_info('2.0.0'));
      await i.install(u);
      expect(events, ['backup', 'instalador']);
      final log = p.join(dir.path, 'logs', 'atualizacao-2.0.0.log');
      expect(started.single, [
        u.installer,
        '/SILENT',
        '/SUPPRESSMSGBOXES',
        '/NORESTART',
        '/WAITAPP',
        '/LOG=$log',
        r'/RELAUNCH=C:\app\patrion.exe',
      ]);
      final pending = jsonDecode(
        (await settings.get(UpdateInstaller.pendingKey))!,
      ) as Map<String, Object?>;
      expect(pending['from'], '1.0.0');
      expect(pending['to'], '2.0.0');
      expect(pending['at'], '2026-11-06T12:00:00.000Z');
    });

    test('ao fechar, não reabre', () async {
      await publish();
      final i = installer();
      await i.install(await i.prepare(_info('2.0.0')), relaunch: false);
      expect(started.single.any((a) => a.startsWith('/RELAUNCH')), isFalse);
      expect(started.single, contains('/WAITAPP'));
    });

    test('arquivo trocado depois da conferência não roda', () async {
      await publish();
      final i = installer();
      final u = await i.prepare(_info('2.0.0'));
      File(u.installer).writeAsStringSync('trocado');
      await expectLater(i.install(u), failsWith(UpdateFailureKind.badHash));
      expect(events, isEmpty);
      expect(await settings.get(UpdateInstaller.pendingKey), isNull);
    });

    test('sem backup, não instala', () async {
      await publish();
      backupError = Exception('disco cheio');
      final i = installer();
      final u = await i.prepare(_info('2.0.0'));
      await expectLater(i.install(u), failsWith(UpdateFailureKind.install));
      expect(started, isEmpty);
      expect(await settings.get(UpdateInstaller.pendingKey), isNull);
    });

    test('instalador que não inicia desfaz o pedido', () async {
      await publish();
      startError = const ProcessException('x', []);
      final i = installer();
      final u = await i.prepare(_info('2.0.0'));
      await expectLater(i.install(u), failsWith(UpdateFailureKind.install));
      final snapshot = UpdateSnapshot(current: Version.parse('1.0.0'));
      expect(await i.takeOutcome(snapshot), isNull);
    });
  });

  group('na abertura seguinte', () {
    Future<UpdateSnapshot> installedThenReopened(String reopened) async {
      await publish();
      final before = installer();
      await before.install(await before.prepare(_info('2.0.0')));
      return UpdateSnapshot(
        current: Version.parse(reopened),
        latest: _info('2.0.0'),
      );
    }

    test('versão nova: atualizado, com as notas, uma vez só', () async {
      final snapshot = await installedThenReopened('2.0.0');
      final i = installer(current: '2.0.0');
      final o = await i.takeOutcome(snapshot);
      expect(o!.updated, isTrue);
      expect(o.to, Version.parse('2.0.0'));
      expect(o.notes, 'Novidades da 2.0.0');
      expect(await i.takeOutcome(snapshot), isNull);
      expectNothingLeft();
    });

    test('mesma versão: instalação não concluída, com o log', () async {
      final snapshot = await installedThenReopened('1.0.0');
      final o = await installer().takeOutcome(snapshot);
      expect(o!.updated, isFalse);
      expect(o.from, Version.parse('1.0.0'));
      expect(o.log, endsWith('atualizacao-2.0.0.log'));
    });

    test('sem pedido, nada a mostrar', () async {
      expect(
        await installer().takeOutcome(
          UpdateSnapshot(current: Version.parse('1.0.0')),
        ),
        isNull,
      );
    });
  });
}
