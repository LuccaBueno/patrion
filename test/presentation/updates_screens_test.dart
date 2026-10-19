import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/updates/update_checker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patrion/presentation/app.dart';
import 'package:patrion/presentation/providers.dart';
import 'package:pub_semver/pub_semver.dart';

import '../helpers/app_harness.dart';
import '../helpers/test_database.dart';

class _Feed implements ReleaseFeed {
  _Feed(this.release);

  final ReleaseInfo? release;

  @override
  Future<ReleaseInfo?> latest({required bool includePrerelease}) async =>
      release;
}

ReleaseInfo _release(String version) => ReleaseInfo(
  version: Version.parse(version),
  tag: 'v$version',
  name: 'Patrion v$version',
  notes: '## Novidades\n- Relatórios em PDF',
  page: Uri.parse('https://github.com/dono/patrion/releases/tag/v$version'),
  prerelease: false,
  publishedAt: DateTime.utc(2026, 11, 2, 15),
);

/// Janela alta: a seção de atualizações fica no fim das Configurações.
const _tall = Size(1280, 2400);

void main() {
  late TestDb t;

  setUp(() async => t = await TestDb.open());
  tearDown(() => t.close());

  testWidgets('verificar agora mostra a versão nova com as notas; abrir '
      'a página e ignorar', (tester) async {
    final opened = <Uri>[];
    final app = AppHarness(tester, t);
    await app.run(
      location: '/configuracoes',
      size: _tall,
      releaseFeed: _Feed(_release('9.1.0')),
      overrides: [
        linkOpenerProvider.overrideWithValue((uri) async {
          opened.add(uri);
          return true;
        }),
      ],
      () async {
        expect(
          find.text('Ainda não verificado neste computador.'),
          findsOneWidget,
        );
        await app.tap(find.byKey(const Key('updates-check-now')));
        expect(
          find.textContaining('Versão 9.1.0 disponível, publicada em'),
          findsOneWidget,
        );
        expect(find.textContaining('Relatórios em PDF'), findsOneWidget);

        await app.tap(find.text('Abrir página de download'));
        expect(opened.single.toString(), endsWith('/releases/tag/v9.1.0'));

        await app.tap(find.text('Ignorar esta versão'));
        expect(find.text('Voltar a avisar'), findsOneWidget);
      },
    );
  });

  testWidgets('sem internet, "verificar agora" explica e não trava', (
    tester,
  ) async {
    final app = AppHarness(tester, t);
    await app.run(location: '/configuracoes', size: _tall, () async {
      await app.tap(find.byKey(const Key('updates-check-now')));
      expect(find.text('Sem conexão.'), findsOneWidget);
      expect(find.byKey(const Key('update-release')), findsNothing);
    });
  });

  testWidgets('Sobre abre as licenças de terceiros com o SQLCipher e o '
      'OpenSSL', (tester) async {
    final app = AppHarness(tester, t);
    await app.run(location: '/configuracoes', size: _tall, () async {
      await app.tap(find.byKey(const Key('third-party-licenses')));
      await app.pumpUntil(find.text('SQLCipher'));
      expect(find.text('OpenSSL'), findsOneWidget);
    });
  });

  testWidgets('o Início avisa da versão nova e o aviso some ao ignorar', (
    tester,
  ) async {
    final app = AppHarness(tester, t);
    await app.run(releaseFeed: _Feed(_release('9.1.0')), () async {
      expect(find.byKey(const Key('update-reminder')), findsNothing);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PatrionApp)),
      );
      await tester.runAsync(
        () => container.read(updateCheckerProvider).checkNow(),
      );
      await app.settle();
      expect(find.text('Nova versão disponível: 9.1.0.'), findsOneWidget);

      await tester.runAsync(
        () =>
            container.read(updateCheckerProvider).skip(Version.parse('9.1.0')),
      );
      await app.settle();
      expect(find.byKey(const Key('update-reminder')), findsNothing);
    });
  });
}
