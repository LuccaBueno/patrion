import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/settings/appearance_service.dart';
import 'package:patrion/data/repositories/device_settings_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late TestDb t;
  late DeviceSettingsRepository settings;
  late AppearanceService service;

  setUp(() async {
    t = await TestDb.open();
    settings = DeviceSettingsRepository(t.db, wallClock: t.wall.clock);
    service = AppearanceService(settings);
  });

  tearDown(() => t.close());

  test('padrão é seguir o Windows', () async {
    expect(await service.theme(), ThemePreference.system);
  });

  test('grava e lê o tema', () async {
    await service.setTheme(ThemePreference.dark);
    expect(await service.theme(), ThemePreference.dark);
    expect(await settings.get(AppearanceService.themeKey), '"dark"');
  });

  test('valor desconhecido ou corrompido volta ao padrão', () async {
    await settings.put(AppearanceService.themeKey, '"neon"');
    expect(await service.theme(), ThemePreference.system);
    await settings.put(AppearanceService.themeKey, '{quebrado');
    expect(await service.theme(), ThemePreference.system);
  });

  test('configuração do dispositivo não é sincronizável', () async {
    await service.setTheme(ThemePreference.light);
    expect(await t.db.sharedSettings.count().getSingle(), 0);
    expect(await t.db.devSettings.count().getSingle(), 1);
  });

  test('watchTheme acompanha as mudanças', () async {
    final stream = service.watchTheme();
    final expectation = expectLater(
      stream,
      emitsInOrder([ThemePreference.system, ThemePreference.light]),
    );
    await Future<void>.delayed(Duration.zero);
    await service.setTheme(ThemePreference.light);
    await expectation;
  });
}
