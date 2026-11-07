import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/updates/update_checker.dart';
import 'package:patrion/application/updates/update_installer.dart';
import 'package:patrion/data/repositories/device_settings_repository.dart';
import 'package:patrion/presentation/app.dart';
import 'package:patrion/presentation/providers.dart';
import 'package:patrion/presentation/router/app_router.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import '../helpers/app_harness.dart';
import '../helpers/test_database.dart';

const _exe = [1, 2, 3, 4];

class _Feed implements ReleaseFeed {
  @override
  Future<ReleaseInfo?> latest({required bool includePrerelease}) async =>
      ReleaseInfo(
        version: Version.parse('9.1.0'),
        tag: 'v9.1.0',
        name: 'Patrion 9.1.0',
        notes: 'Relatórios em PDF',
        page: Uri.parse('https://github.com/dono/patrion/releases/tag/v9.1.0'),
        prerelease: false,
      );
}

class _Downloads implements UpdateDownloads {
  UpdateFailure? error;

  /// Segura o download até ser completado (para ver a barra e cancelar).
  Completer<void>? gate;

  @override
  Future<Uint8List?> fetch(Uri uri) async => Uint8List.fromList(
    utf8.encode('${sha256.convert(_exe)}  Patrion-9.1.0-instalador.exe\n'),
  );

  @override
  Future<void> download(
    Uri uri,
    String target, {
    void Function(int received, int? total)? onProgress,
    UpdateCancel? cancel,
  }) async {
    onProgress?.call(2 * 1024 * 1024, 4 * 1024 * 1024);
    cancel?.onCancel = () => gate?.complete();
    await gate?.future;
    if (cancel?.cancelled ?? false) {
      throw const UpdateFailure(UpdateFailureKind.cancelled, 'cancelado');
    }
    if (error != null) throw error!;
    File(target).writeAsBytesSync(_exe);
  }
}

void main() {
  late TestDb t;
  late Directory dir;
  late _Downloads downloads;
  late List<String> events;
  late bool signatureOk;
  late Future<void> Function()? closeHook;

  setUp(() async {
    t = await TestDb.open();
    dir = Directory.systemTemp.createTempSync('patrion_ui');
    downloads = _Downloads();
    events = [];
    signatureOk = true;
    closeHook = null;
  });
  tearDown(() async {
    await t.close();
    dir.deleteSync(recursive: true);
  });

  UpdateInstaller installer(String current) => UpdateInstaller(
    downloads: downloads,
    checkSignature: (_, _) async => signatureOk,
    settings: DeviceSettingsRepository(t.db),
    current: Version.parse(current),
    startInstaller: (_, arguments) async =>
        events.add('instalador ${arguments.last}'),
    backup: () async => events.add('backup'),
    repository: 'dono/patrion',
    cacheDir: dir.path,
    logsDir: dir.path,
    relaunchArguments: const ['/RELAUNCH=patrion.exe'],
    clock: Clock.fixed(DateTime.utc(2026, 11, 6, 12)),
  );

  List<Override> installed({String current = '1.0.0'}) => [
    selfUpdateAvailableProvider.overrideWithValue(true),
    updateInstallerProvider.overrideWithValue(installer(current)),
    appQuitProvider.overrideWithValue(() async => events.add('fechou')),
    beforeWindowClosesProvider.overrideWithValue((action) async {
      closeHook = action;
    }),
  ];

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(PatrionApp)));

  Future<void> check(WidgetTester tester, AppHarness app) async {
    await tester.runAsync(
      () => container(tester).read(updateCheckerProvider).checkNow(),
    );
    await app.settle();
  }

  /// Com [installs], a barra fica animando (no app real, o processo termina).
  Future<void> tapUpdate(
    WidgetTester tester,
    AppHarness app, {
    bool installs = false,
  }) async {
    await tester.tap(find.byKey(const Key('update-now')).first);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    if (installs) {
      for (var i = 0; i < 40 && !events.contains('fechou'); i++) {
        await tester.pump();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
      }
    } else {
      await app.settle();
    }
  }

  testWidgets('Atualizar agora no Painel: baixa, confere, faz backup, abre o '
      'instalador e fecha', (tester) async {
    final app = AppHarness(tester, t);
    await app.run(releaseFeed: _Feed(), overrides: installed(), () async {
      await check(tester, app);
      expect(find.text('Nova versão disponível: 9.1.0.'), findsOneWidget);
      await tapUpdate(tester, app, installs: true);
      expect(events, ['backup', 'instalador /RELAUNCH=patrion.exe', 'fechou']);
    });
  });

  testWidgets('Sobre mostra as versões, a barra de progresso e cancela', (
    tester,
  ) async {
    downloads.gate = Completer<void>();
    final app = AppHarness(tester, t);
    await app.run(
      location: Routes.about,
      size: const Size(1280, 2400),
      releaseFeed: _Feed(),
      overrides: installed(),
      () async {
        await check(tester, app);
        expect(find.textContaining('Mais recente: 9.1.0'), findsOneWidget);
        await tapUpdate(tester, app);
        expect(find.byKey(const Key('update-progress')), findsOneWidget);
        expect(find.textContaining('2,0 de 4,0 MB'), findsOneWidget);
        await app.tap(find.byKey(const Key('update-cancel')));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await app.settle();
        expect(find.byKey(const Key('update-progress')), findsNothing);
        expect(find.byKey(const Key('update-error')), findsNothing);
        expect(events, isEmpty);
      },
    );
  });

  testWidgets('assinatura inválida: mensagem clara, nada instalado, app '
      'aberto', (tester) async {
    signatureOk = false;
    final app = AppHarness(tester, t);
    await app.run(
      location: Routes.about,
      size: const Size(1280, 2400),
      releaseFeed: _Feed(),
      overrides: installed(),
      () async {
        await check(tester, app);
        await tapUpdate(tester, app);
        expect(
          find.textContaining('A assinatura desta versão é inválida'),
          findsOneWidget,
        );
        expect(events, isEmpty);
        // Dá para tentar de novo.
        signatureOk = true;
        await tapUpdate(tester, app, installs: true);
        expect(events, contains('fechou'));
      },
    );
  });

  testWidgets('sem internet: diz isso e continua', (tester) async {
    downloads.error = const UpdateFailure(
      UpdateFailureKind.offline,
      'Sem conexão com a internet. Sua versão continua funcionando.',
    );
    final app = AppHarness(tester, t);
    await app.run(releaseFeed: _Feed(), overrides: installed(), () async {
      await check(tester, app);
      await tapUpdate(tester, app);
      expect(find.textContaining('Sem conexão com a internet'), findsOneWidget);
      expect(events, isEmpty);
    });
  });

  testWidgets('versão portátil: sem o botão, com a explicação', (tester) async {
    final app = AppHarness(tester, t);
    await app.run(
      location: Routes.about,
      size: const Size(1280, 2400),
      releaseFeed: _Feed(),
      () async {
        await check(tester, app);
        expect(find.byKey(const Key('updates-portable')), findsOneWidget);
        expect(find.byKey(const Key('update-now')), findsNothing);
        expect(find.byKey(const Key('updates-install-on-close')), findsNothing);
        expect(find.text('Abrir página de download'), findsOneWidget);
      },
    );
  });

  group('na reabertura', () {
    Future<void> pending() async {
      final i = installer('1.0.0');
      final file = File(p.join(dir.path, 'x.exe'))..writeAsBytesSync(_exe);
      await i.install(
        PreparedUpdate(
          release: (await _Feed().latest(includePrerelease: false))!,
          installer: file.path,
          sha256: sha256.convert(_exe).toString(),
        ),
      );
      events.clear();
    }

    testWidgets('mostra "Atualizado para a versão X" com as notas', (
      tester,
    ) async {
      await tester.runAsync(pending);
      await tester.runAsync(
        () => DeviceSettingsRepository(t.db).put(
          UpdateChecker.stateKey,
          jsonEncode({
            'latest': {
              'version': '9.1.0',
              'tag': 'v9.1.0',
              'notes': 'Relatórios em PDF',
              'page': 'https://github.com/dono/patrion',
            },
          }),
        ),
      );
      final app = AppHarness(tester, t);
      await app.run(overrides: installed(current: '9.1.0'), () async {
        expect(find.text('Atualizado para a versão 9.1.0.'), findsOneWidget);
        expect(find.text('Relatórios em PDF'), findsOneWidget);
        await app.tap(find.byTooltip('Fechar'));
        expect(find.byKey(const Key('update-outcome')), findsNothing);
      });
    });

    testWidgets('falhou: a versão continua, com o log e o backup', (
      tester,
    ) async {
      await tester.runAsync(pending);
      final app = AppHarness(tester, t);
      await app.run(overrides: installed(), () async {
        expect(
          find.text('A atualização para a versão 9.1.0 não foi concluída.'),
          findsOneWidget,
        );
        expect(find.textContaining('atualizacao-9.1.0.log'), findsOneWidget);
      });
    });
  });

  testWidgets('instalar ao fechar: baixa em segundo plano e só instala '
      'quando a janela fecha, sem reabrir', (tester) async {
    final app = AppHarness(tester, t);
    await app.run(
      location: Routes.about,
      size: const Size(1280, 2400),
      releaseFeed: _Feed(),
      overrides: installed(),
      () async {
        await app.tap(find.byKey(const Key('updates-install-on-close')));
        await check(tester, app);
        final task = container(tester).read(updateTaskProvider.notifier);
        final release = await _Feed().latest(includePrerelease: false);
        await tester.runAsync(() => task.prepareInBackground(release!));
        expect(events, isEmpty);
        expect(closeHook, isNotNull);
        await tester.runAsync(closeHook!);
        expect(events.first, 'backup');
        expect(events[1], startsWith('instalador /LOG='));
        expect(events.last, 'fechou');
      },
    );
  });
}
