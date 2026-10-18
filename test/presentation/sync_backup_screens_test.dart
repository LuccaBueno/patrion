import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/core/config/app_paths.dart';
import 'package:patrion/core/time/instant_format.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/sync/invsave_codec.dart';
import 'package:patrion/presentation/providers.dart';
import 'package:patrion/presentation/services/file_dialogs.dart';

import '../helpers/app_harness.dart';
import '../helpers/portfolio_fixture.dart';
import '../helpers/sync_pc.dart';

class _FakeDialogs implements FileDialogs {
  _FakeDialogs(this.dir);

  final String dir;
  String? fileToPick;
  final saved = <String>[];

  @override
  Future<String?> saveBytes({
    required String dialogTitle,
    required String suggestedName,
    required String extension,
    required Uint8List bytes,
  }) async {
    final path = p.join(dir, suggestedName);
    File(path).writeAsBytesSync(bytes);
    saved.add(path);
    return path;
  }

  @override
  Future<String?> pickFile({
    required String dialogTitle,
    required List<String> extensions,
  }) async => fileToPick;

  @override
  Future<String?> pickDirectory({required String dialogTitle}) async => dir;
}

class _FakeSession extends ChangeNotifier implements SessionController {
  final restored = <String>[];

  @override
  Future<void> restore(String path, {String? backupSecret}) async =>
      restored.add(path);

  @override
  bool get lockEnabled => false;

  @override
  bool get helloEnabled => false;

  @override
  Future<bool> helloAvailable() async => false;

  @override
  String? takePendingRecoveryKey() => null;

  // O resto do bloqueio não é usado nestes testes.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('patrion_ui_sync_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  AppPaths pathsIn(String name) => AppPaths(
    dataDir: p.join(tmp.path, name),
    cacheDir: p.join(tmp.path, '$name-cache'),
  );

  testWidgets('salvar arquivo de save grava o arquivo e mostra o resumo', (
    tester,
  ) async {
    final pc = (await tester.runAsync(() => SyncPc.open('PC-A', tmp)))!;
    await tester.runAsync(() async {
      final inst = await pc.institution('Corretora');
      await pc.account(inst, 'Principal');
    });
    final dialogs = _FakeDialogs(tmp.path);
    final h = AppHarness(tester, pc.t);

    await h.run(
      () async {
        await h.press(find.text('Salvar arquivo de save'));
        await h.pumpUntil(find.text('Proteger o arquivo com senha'));
        await h.press(find.text('Continuar'));
        await h.pumpUntil(find.text('Arquivo de save salvo'));
        expect(find.textContaining('sem senha'), findsOneWidget);

        expect(find.text('Arquivo de save salvo'), findsOneWidget);
        expect(dialogs.saved.single, endsWith('.invsave'));
        expect(p.basename(dialogs.saved.single), startsWith('Patrion_PC-A_'));
        await h.tap(find.text('OK'));
        // O histórico mostra a exportação.
        await h.pumpUntil(find.textContaining('Exportado'));
      },
      location: '/sincronizacao',
      paths: pathsIn('a'),
      overrides: [fileDialogsProvider.overrideWithValue(dialogs)],
    );
    await tester.runAsync(pc.close);
  });

  testWidgets('salvar com senha e importar em outro PC pedindo a senha', (
    tester,
  ) async {
    final a = (await tester.runAsync(() => SyncPc.open('PC-A', tmp)))!;
    final b = (await tester.runAsync(() => SyncPc.open('PC-B', tmp)))!;
    await tester.runAsync(() async {
      await a.institution('Corretora Protegida');
    });
    final dialogs = _FakeDialogs(tmp.path);

    final ha = AppHarness(tester, a.t);
    await ha.run(
      () async {
        await ha.press(find.text('Salvar arquivo de save'));
        await ha.pumpUntil(find.text('Proteger o arquivo com senha'));
        await ha.press(find.byKey(const Key('save-protect')));
        await ha.type(find.byKey(const Key('save-password')), 'senha-arq-1');
        await ha.type(
          find.byKey(const Key('save-password-confirm')),
          'senha-arq-1',
        );
        await ha.press(find.text('Continuar'));
        await ha.pumpUntil(find.text('Arquivo de save salvo'));
        expect(find.textContaining('protegido por senha'), findsOneWidget);
        await ha.tap(find.text('OK'));
      },
      location: '/sincronizacao',
      paths: pathsIn('a'),
      overrides: [fileDialogsProvider.overrideWithValue(dialogs)],
    );
    final saved = dialogs.saved.single;
    expect(InvsaveCodec.isProtected(File(saved).readAsBytesSync()), isTrue);

    dialogs.fileToPick = saved;
    final hb = AppHarness(tester, b.t);
    await hb.run(
      () async {
        await hb.press(find.text('Importar save…'));
        await hb.pumpUntil(find.text('Arquivo protegido por senha'));
        await hb.type(find.byKey(const Key('prompt-password')), 'errada-12');
        await hb.press(find.text('Abrir'));
        await hb.pumpUntil(find.text('Não foi possível concluir'));
        expect(
          find.textContaining('Senha do arquivo incorreta'),
          findsOneWidget,
        );
        await hb.tap(find.text('Fechar'));

        await hb.press(find.text('Importar save…'));
        await hb.pumpUntil(find.text('Arquivo protegido por senha'));
        await hb.type(find.byKey(const Key('prompt-password')), 'senha-arq-1');
        await hb.press(find.text('Abrir'));
        await hb.pumpUntil(find.text('Prévia da importação'));
        await hb.press(find.text('Aplicar'));
        await hb.pumpUntil(find.textContaining('Importação concluída'));
      },
      location: '/sincronizacao',
      paths: pathsIn('b'),
      overrides: [fileDialogsProvider.overrideWithValue(dialogs)],
    );
    final names = await tester.runAsync(
      () async => [for (final i in await b.repos.institutions.all()) i.name],
    );
    expect(names, contains('Corretora Protegida'));
    await tester.runAsync(() async {
      await a.close();
      await b.close();
    });
  });

  testWidgets('importar mostra a prévia com o conflito; escolher a versão '
      'recebida e aplicar', (tester) async {
    final a = (await tester.runAsync(() => SyncPc.open('PC-A', tmp)))!;
    final b = (await tester.runAsync(() => SyncPc.open('PC-B', tmp)))!;
    late String o1;
    final saveFile = p.join(tmp.path, 'de-a.invsave');
    await tester.runAsync(() async {
      final inst = await a.institution('Corretora');
      final acc = await a.account(inst, 'Principal');
      final asset = await a.stock('VALE3');
      o1 = await a.buy(acc, asset, '10');
      await syncBoth(a, b);
      await a.editBuy(o1, acc, asset, '20');
      b.tick(const Duration(hours: 1));
      await b.editBuy(o1, acc, asset, '30');
      File(saveFile).writeAsBytesSync(await a.export());
    });
    final dialogs = _FakeDialogs(tmp.path)..fileToPick = saveFile;
    final h = AppHarness(tester, b.t);

    await h.run(
      () async {
        await h.press(find.text('Importar save…'));
        await h.pumpUntil(find.text('Prévia da importação'));
        expect(find.text('Conflitos (1)'), findsOneWidget);
        expect(
          find.text('Manter a deste computador (mais recente)'),
          findsOneWidget,
        );
        await h.press(find.text('Usar a recebida'));
        await h.press(find.text('Aplicar'));
        await h.pumpUntil(find.textContaining('Importação concluída'));
        await h.pumpUntil(find.textContaining('Importado de PC-A'));
        expect(find.text('PC-A'), findsOneWidget); // computadores
      },
      location: '/sincronizacao',
      paths: pathsIn('b'),
      overrides: [fileDialogsProvider.overrideWithValue(dialogs)],
    );
    final row = await tester.runAsync(() => b.row('operations', o1));
    expect(row!['quantity'], '20');
    await tester.runAsync(() async {
      await a.close();
      await b.close();
    });
  });

  testWidgets('prévia avisa, antes de aplicar, que a carteira fica com uma '
      'venda maior que a posição', (tester) async {
    final a = (await tester.runAsync(() => SyncPc.open('PC-A', tmp)))!;
    final b = (await tester.runAsync(() => SyncPc.open('PC-B', tmp)))!;
    final saveFile = p.join(tmp.path, 'de-a.invsave');
    await tester.runAsync(() async {
      final inst = await a.institution('Corretora');
      final acc = await a.account(inst, 'Principal');
      final asset = await a.stock('VALE3');
      await a.buy(acc, asset, '100');
      await syncBoth(a, b);
      await a.sell(acc, asset, '80');
      await b.sell(acc, asset, '50', date: '2026-02-11');
      File(saveFile).writeAsBytesSync(await a.export());
    });
    final dialogs = _FakeDialogs(tmp.path)..fileToPick = saveFile;
    final h = AppHarness(tester, b.t);

    await h.run(
      () async {
        await h.press(find.text('Importar save…'));
        await h.pumpUntil(find.text('Prévia da importação'));
        expect(find.byKey(const Key('import-warnings')), findsOneWidget);
        expect(
          find.text(
            'Depois de aplicar, a carteira fica com 1 operação inconsistente',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Venda VALE3 em Corretora · Principal, '
            '11/02/2026: a quantidade vendida',
          ),
          findsOneWidget,
        );
        await h.press(find.text('Cancelar'));
      },
      location: '/sincronizacao',
      paths: pathsIn('b'),
      overrides: [fileDialogsProvider.overrideWithValue(dialogs)],
    );
    await tester.runAsync(() async {
      await a.close();
      await b.close();
    });
  });

  testWidgets('arquivo que não é save é recusado com mensagem', (tester) async {
    final pc = (await tester.runAsync(() => SyncPc.open('PC-A', tmp)))!;
    final bad = File(p.join(tmp.path, 'ruim.invsave'))..writeAsStringSync('x');
    final dialogs = _FakeDialogs(tmp.path)..fileToPick = bad.path;
    final h = AppHarness(tester, pc.t);

    await h.run(
      () async {
        await h.press(find.text('Importar save…'));
        await h.pumpUntil(find.text('Não foi possível concluir'));
        expect(find.textContaining('Nada foi importado'), findsOneWidget);
      },
      location: '/sincronizacao',
      paths: pathsIn('a'),
      overrides: [fileDialogsProvider.overrideWithValue(dialogs)],
    );
    await tester.runAsync(pc.close);
  });

  testWidgets('backup agora aparece na lista; restaurar pede confirmação '
      'explícita', (tester) async {
    final pc = (await tester.runAsync(() => SyncPc.open('PC-A', tmp)))!;
    final session = _FakeSession();
    final h = AppHarness(tester, pc.t);
    final paths = pathsIn('a');

    await h.run(
      () async {
        await h.press(find.text('Fazer backup agora'));
        await h.pumpUntil(find.textContaining('Backup criado e verificado'));
        await h.pumpUntil(find.textContaining('· Manual'));

        await h.press(find.widgetWithText(TextButton, 'Restaurar'));
        await h.pumpUntil(find.text('Restaurar este backup?'));
        final confirm = find.widgetWithText(FilledButton, 'Restaurar');
        expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
        await h.press(
          find.text('Entendo que os dados atuais serão substituídos'),
        );
        await h.press(confirm);
        for (var i = 0; i < 50 && session.restored.isEmpty; i++) {
          await h.pumpUntil(find.byType(Scaffold));
        }
        expect(session.restored, hasLength(1));
        expect(session.restored.single, startsWith(paths.backupsDir));
      },
      location: '/backup',
      paths: paths,
      overrides: [sessionControllerProvider.overrideWithValue(session)],
    );
    await tester.runAsync(pc.close);
  });

  testWidgets('Início avisa, sem bloquear, quando a última sincronização é '
      'antiga', (tester) async {
    final pc = (await tester.runAsync(() => SyncPc.open('PC-A', tmp)))!;
    await tester.runAsync(() async {
      final f = await PortfolioFixture.open(db: pc.t);
      await f.add(
        f.draft(OperationType.buy, '2026-01-05', qty: '1', price: '10'),
      );
      await pc.peers.recordImport(
        deviceId: '0199f2a0-0000-7000-8000-0000000000ff',
        deviceName: 'PC-NOTEBOOK',
        maxHlc: '001760702400000-00000-x',
        knownHlcOfThisDevice: null,
        at: formatInstant(
          DateTime.now().subtract(const Duration(days: 10, hours: 1)),
        ),
      );
    });
    final h = AppHarness(tester, pc.t);

    await h.run(() async {
      expect(
        find.textContaining('A última sincronização com PC-NOTEBOOK foi há 10'),
        findsOneWidget,
      );
      expect(find.text('Sincronizar'), findsOneWidget);
    });
    await tester.runAsync(pc.close);
  });
}
