import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/updates/update_checker.dart';
import 'package:patrion/data/repositories/device_settings_repository.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../helpers/test_database.dart';

ReleaseInfo _info(String version, {bool prerelease = false}) => ReleaseInfo(
  version: Version.parse(version),
  tag: 'v$version',
  name: 'Patrion v$version',
  notes: 'notas',
  page: Uri.parse('https://github.com/dono/patrion/releases/tag/v$version'),
  prerelease: prerelease,
  publishedAt: DateTime.utc(2026, 10, 20),
);

class _Feed implements ReleaseFeed {
  ReleaseInfo? stable;
  ReleaseInfo? pre;
  Object? error;
  final calls = <bool>[];

  @override
  Future<ReleaseInfo?> latest({required bool includePrerelease}) async {
    calls.add(includePrerelease);
    if (error != null) throw error!;
    final s = stable;
    final p = pre;
    if (includePrerelease && p != null) {
      return s == null || p.version > s.version ? p : s;
    }
    return s;
  }
}

void main() {
  late TestDb t;
  late _Feed feed;
  late DateTime now;
  late UpdateChecker checker;

  setUp(() async {
    t = await TestDb.open();
    feed = _Feed();
    now = DateTime.utc(2026, 10, 18, 12);
    checker = UpdateChecker(
      settings: DeviceSettingsRepository(t.db),
      feed: feed,
      current: Version.parse('1.0.0'),
      clock: Clock(() => now),
    );
  });
  tearDown(() => t.close());

  test('versão mais nova fica disponível; igual, não', () async {
    feed.stable = _info('1.0.1');
    var s = await checker.checkNow();
    expect(s.available?.version.toString(), '1.0.1');
    expect(s.checkedAt, now);

    feed.stable = _info('1.0.0');
    now = now.add(const Duration(minutes: 2));
    s = await checker.checkNow();
    expect(s.available, isNull);
    expect(s.newer, isNull);
  });

  test('pré-lançamentos são ignorados por padrão', () async {
    feed
      ..stable = _info('1.0.0')
      ..pre = _info('1.1.0-beta.1', prerelease: true);
    var s = await checker.checkNow();
    expect(feed.calls.single, isFalse);
    expect(s.available, isNull);

    await checker.setIncludePrerelease(true);
    s = await checker.checkNow();
    expect(feed.calls.last, isTrue);
    expect(s.available?.version.toString(), '1.1.0-beta.1');

    // Desligar de novo esconde o pré-lançamento.
    await checker.setIncludePrerelease(false);
    expect((await checker.snapshot()).available, isNull);
  });

  test('a automática roda no máximo uma vez por dia e pode ser '
      'desligada', () async {
    feed.stable = _info('1.1.0');
    await checker.checkIfDue();
    await checker.checkIfDue();
    expect(feed.calls, hasLength(1));

    now = now.add(const Duration(hours: 25));
    await checker.checkIfDue();
    expect(feed.calls, hasLength(2));

    await checker.setAutomatic(false);
    now = now.add(const Duration(days: 3));
    await checker.checkIfDue();
    expect(feed.calls, hasLength(2));
  });

  test('a manual respeita o intervalo mínimo entre consultas', () async {
    feed.stable = _info('1.1.0');
    await checker.checkNow();
    await checker.checkNow();
    expect(feed.calls, hasLength(1));
    now = now.add(UpdateChecker.manualInterval);
    await checker.checkNow();
    expect(feed.calls, hasLength(2));
  });

  test('sem internet a automática não lança e mantém o último '
      'resultado', () async {
    feed.stable = _info('1.1.0');
    await checker.checkNow();
    feed.error = const UpdateCheckFailure('Sem conexão.', offline: true);
    now = now.add(const Duration(days: 2));
    final s = await checker.checkIfDue();
    expect(s.available?.version.toString(), '1.1.0');
    expect(s.checkedAt, DateTime.utc(2026, 10, 18, 12));
    // A manual mostra o erro.
    now = now.add(const Duration(minutes: 5));
    await expectLater(checker.checkNow(), throwsA(isA<UpdateCheckFailure>()));
  });

  test('ignorar uma versão tira o aviso só dela', () async {
    feed.stable = _info('1.1.0');
    await checker.checkNow();
    await checker.skip(Version.parse('1.1.0'));
    var s = await checker.snapshot();
    expect(s.available, isNull);
    expect(s.newer?.version.toString(), '1.1.0');

    feed.stable = _info('1.2.0');
    now = now.add(const Duration(minutes: 5));
    s = await checker.checkNow();
    expect(s.available?.version.toString(), '1.2.0');
  });

  test('o estado fica no banco e vale para uma nova instância', () async {
    feed.stable = _info('1.1.0');
    await checker.checkNow();
    final other = UpdateChecker(
      settings: DeviceSettingsRepository(t.db),
      feed: feed,
      current: Version.parse('1.0.0'),
      clock: Clock(() => now),
    );
    final s = await other.snapshot();
    expect(s.latest?.notes, 'notas');
    expect(s.latest?.page.host, 'github.com');
    expect(s.available?.version.toString(), '1.1.0');
  });
}
