import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/config/app_info.dart';
import 'package:patrion/core/config/app_paths.dart';
import 'package:patrion/presentation/app.dart';
import 'package:patrion/presentation/providers.dart';

import 'test_database.dart';

/// Monta o app inteiro sobre um banco de teste.
class AppHarness {
  AppHarness(this.tester, this.t);

  final WidgetTester tester;
  final TestDb t;

  Future<void> pump({
    String location = '/',
    Size size = const Size(1280, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            AppEnvironment(
              paths: const AppPaths(
                dataDir: r'C:\dados',
                cacheDir: r'C:\cache',
              ),
              deviceId: t.identity.deviceId,
              deviceName: t.identity.deviceName,
              appVersion: AppInfo.version,
            ),
          ),
          databaseProvider.overrideWithValue(t.db),
          syncContextProvider.overrideWithValue(t.sync),
        ],
        child: PatrionApp(initialLocation: location),
      ),
    );
    await settle();
  }

  /// As consultas do Drift rodam fora do relógio falso do teste: deixa o
  /// tempo real andar um pouco e redesenha, algumas vezes.
  Future<void> settle() async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  /// Desmonta o app e deixa o Drift encerrar os streams (ele usa um timer).
  Future<void> unmount() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  /// Monta, roda [body] e sempre desmonta (sem isso o fechamento do banco
  /// trava a execução dos testes).
  Future<void> run(
    Future<void> Function() body, {
    String location = '/',
    Size size = const Size(1280, 900),
  }) async {
    await pump(location: location, size: size);
    try {
      await body();
    } finally {
      await unmount();
    }
  }

  Future<void> tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await settle();
  }

  /// Escolhe [option] na lista suspensa [dropdown].
  Future<void> choose(Finder dropdown, String option) async {
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  Future<void> type(Finder field, String text) async {
    await tester.ensureVisible(field);
    await tester.enterText(field, text);
    await tester.pump();
  }
}
