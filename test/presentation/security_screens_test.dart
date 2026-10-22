import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/presentation/router/app_router.dart';
import 'package:patrion/application/settings/lock_preferences.dart';
import 'package:patrion/core/config/app_paths.dart';
import 'package:patrion/core/crypto/crypto_box.dart';
import 'package:patrion/data/repositories/device_settings_repository.dart';
import 'package:patrion/presentation/providers.dart';
import 'package:patrion/presentation/screens/security/security_dialogs.dart';
import 'package:patrion/presentation/screens/security/unlock_screen.dart';
import 'package:patrion/presentation/session/app_session.dart';
import 'package:patrion/presentation/session/inactivity_guard.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_security.dart';
import '../helpers/test_database.dart';

class _FakeLock extends ChangeNotifier implements SessionController {
  _FakeLock({this.lockEnabled = false});

  @override
  bool lockEnabled;

  @override
  bool helloEnabled = false;

  final calls = <String>[];
  String? pending;

  @override
  Future<bool> helloAvailable() async => true;

  @override
  Future<String> enableLock(
    String password, {
    bool encryptBackups = true,
  }) async {
    calls.add('enable:$password:$encryptBackups');
    lockEnabled = true;
    notifyListeners();
    return 'CODE';
  }

  @override
  String? takePendingRecoveryKey() {
    final code = pending;
    pending = null;
    return code;
  }

  @override
  Future<void> lockNow() async => calls.add('lock');

  @override
  Future<void> changePassword(String current, String next) async =>
      calls.add('change:$current:$next');

  @override
  Future<void> disableLock(String password) async =>
      calls.add('disable:$password');

  @override
  Future<String> newRecoveryKey(String password) async => 'NOVA';

  @override
  Future<void> setHello(bool enabled) async {
    calls.add('hello:$enabled');
    helloEnabled = enabled;
    notifyListeners();
  }

  @override
  Future<void> restore(String path, {String? backupSecret}) async {}
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('bloqueio por inatividade', () {
    Future<List<int>> pumpGuard(
      WidgetTester tester, {
      required int minutes,
      bool enabled = true,
    }) async {
      final idle = <int>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            idleMinutesProvider.overrideWith((ref) => Stream.value(minutes)),
          ],
          child: InactivityGuard(
            enabled: enabled,
            onIdle: () async => idle.add(1),
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: TextButton(onPressed: () {}, child: const Text('Ok')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return idle;
    }

    testWidgets('sem uso pelo tempo configurado, bloqueia; o uso adia', (
      tester,
    ) async {
      final idle = await pumpGuard(tester, minutes: 1);
      await tester.pump(const Duration(seconds: 50));
      await tester.tap(find.text('Ok'));
      await tester.pump(const Duration(seconds: 50));
      expect(idle, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump(const Duration(seconds: 59));
      expect(idle, isEmpty);
      await tester.pump(const Duration(seconds: 2));
      expect(idle, hasLength(1));
    });

    testWidgets('"Nunca" e bloqueio desativado não bloqueiam', (tester) async {
      final never = await pumpGuard(tester, minutes: 0);
      await tester.pump(const Duration(hours: 3));
      expect(never, isEmpty);

      final off = await pumpGuard(tester, minutes: 1, enabled: false);
      await tester.pump(const Duration(minutes: 5));
      expect(off, isEmpty);
    });
  });

  group('Configurações', () {
    late TestDb t;

    setUp(() async => t = await TestDb.open());
    tearDown(() => t.close());

    testWidgets('ativar pede a senha duas vezes, com as regras', (
      tester,
    ) async {
      final lock = _FakeLock();
      final h = AppHarness(tester, t);
      await h.run(
        () async {
          await h.tap(find.text('Ativar o bloqueio…'));
          expect(find.text('Ativar o bloqueio'), findsOneWidget);
          await h.type(find.byKey(const Key('new-password')), 'curta');
          await h.type(find.byKey(const Key('new-password-confirm')), 'x');
          await h.tap(find.text('Ativar'));
          expect(find.text('Use pelo menos 8 caracteres.'), findsOneWidget);
          expect(find.text('As senhas não são iguais.'), findsOneWidget);
          expect(lock.calls, isEmpty);

          await h.type(find.byKey(const Key('new-password')), 'senha-boa-1');
          await h.type(
            find.byKey(const Key('new-password-confirm')),
            'senha-boa-1',
          );
          await h.tap(find.text('Ativar'));
          expect(lock.calls, ['enable:senha-boa-1:true']);
          // Ativado: as opções aparecem.
          expect(find.text('Bloquear agora'), findsOneWidget);
          expect(find.text('Desbloquear com o Windows Hello'), findsOneWidget);
        },
        location: Routes.security,
        overrides: [sessionControllerProvider.overrideWithValue(lock)],
      );
    });

    testWidgets('com o bloqueio ativo: tempo de inatividade, bloquear agora, '
        'Windows Hello e chave de recuperação pendente', (tester) async {
      final lock = _FakeLock(lockEnabled: true)..pending = 'AAAA-BBBB';
      final h = AppHarness(tester, t);
      await h.run(
        () async {
          // A chave de recuperação da ativação aparece ao montar a tela.
          expect(find.text('AAAA-BBBB'), findsOneWidget);
          final done = find.widgetWithText(FilledButton, 'Concluir');
          expect(tester.widget<FilledButton>(done).onPressed, isNull);
          await h.tap(find.text('Guardei a chave de recuperação'));
          await h.tap(done);
          expect(find.text('AAAA-BBBB'), findsNothing);

          await h.choose(find.byKey(const Key('idle-minutes')), '5 minutos');
          await h.settle();
          final saved = await tester.runAsync(
            () => DeviceSettingsRepository(t.db).get(LockPreferences.idleKey),
          );
          expect(saved, '5');

          await h.tap(find.text('Bloquear agora'));
          await h.tap(find.text('Desbloquear com o Windows Hello'));
          expect(lock.calls, ['lock', 'hello:true']);
        },
        location: Routes.security,
        // Janela alta: a tela inteira cabe, sem rolagem no meio do teste.
        size: const Size(1280, 2400),
        overrides: [sessionControllerProvider.overrideWithValue(lock)],
      );
    });
  });

  testWidgets('tela de desbloqueio: senha errada avisa e continua bloqueado; '
      '"Esqueci a senha" pede a chave e a nova senha', (tester) async {
    final tmp = Directory.systemTemp.createTempSync('patrion_unlock_ui_');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final paths = AppPaths(
      dataDir: p.join(tmp.path, 'dados'),
      cacheDir: p.join(tmp.path, 'cache'),
    );
    Directory(paths.dataDir).createSync(recursive: true);
    final manager = SessionManager(
      paths: paths,
      hello: FakeHello(),
      helloVault: MemoryHelloVault(),
      beforeClose: () async {},
      kdfPolicy: KdfPolicy.fastForTests,
    );
    await tester.runAsync(() async {
      await manager.start();
      await manager.enableLock('senha-certa-1');
      await manager.lockNow();
    });
    expect(manager.phase, SessionPhase.locked);

    await tester.pumpWidget(UnlockApp(manager: manager));
    await tester.pumpAndSettle();
    expect(find.text('Patrion bloqueado'), findsOneWidget);
    expect(find.text('Usar o Windows Hello'), findsNothing);

    await tester.enterText(find.byKey(const Key('unlock-password')), 'errada');
    await tester.tap(find.text('Desbloquear'));
    await tester.pumpAndSettle();
    expect(find.text('Senha incorreta.'), findsOneWidget);
    expect(manager.phase, SessionPhase.locked);
    // O cursor volta ao campo da senha.
    final field = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('unlock-password')),
        matching: find.byType(EditableText),
      ),
    );
    expect(field.focusNode.hasFocus, isTrue);

    await tester.tap(find.text('Esqueci a senha'));
    await tester.pumpAndSettle();
    expect(find.text('Recuperar o acesso'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('recovery-key')), 'ABC');
    await tester.tap(find.text('Recuperar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('A chave tem 32 letras'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    await tester.runAsync(() => manager.unlockWithPassword('senha-certa-1'));
    expect(manager.phase, SessionPhase.ready);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(manager.session.db.close);
  });

  testWidgets('a chave de recuperação só fecha depois de confirmar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RecoveryKeyDialog(code: 'XXXX')),
    );
    final done = find.widgetWithText(FilledButton, 'Concluir');
    expect(tester.widget<FilledButton>(done).onPressed, isNull);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<FilledButton>(done).onPressed, isNotNull);
  });
}
