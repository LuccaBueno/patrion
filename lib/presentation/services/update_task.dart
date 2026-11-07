import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../application/updates/update_checker.dart';
import '../../application/updates/update_installer.dart';
import '../providers.dart';

final _log = Logger('updates');

enum UpdatePhase { idle, downloading, installing, failed }

/// Andamento de "Atualizar agora", para a interface.
class UpdateTaskState {
  const UpdateTaskState({
    this.phase = UpdatePhase.idle,
    this.received = 0,
    this.total,
    this.message,
  });

  final UpdatePhase phase;
  final int received;
  final int? total;

  /// Motivo da falha.
  final String? message;

  bool get busy =>
      phase == UpdatePhase.downloading || phase == UpdatePhase.installing;

  /// Fração baixada; nula sem o tamanho.
  double? get fraction {
    final t = total;
    return t == null || t <= 0 ? null : received / t;
  }
}

/// Baixa, confere e instala uma versão nova (M-14). Uma falha nunca derruba
/// o app: a versão atual continua aberta, com a mensagem.
class UpdateTask extends Notifier<UpdateTaskState> {
  UpdateCancel? _cancel;
  PreparedUpdate? _ready;
  var _closeHookSet = false;

  @override
  UpdateTaskState build() => const UpdateTaskState();

  Future<void> updateNow(ReleaseInfo release) async {
    if (state.busy) return;
    final installer = ref.read(updateInstallerProvider);
    try {
      final update = await _prepared(release);
      state = const UpdateTaskState(phase: UpdatePhase.installing);
      await installer.install(update);
      _ready = null;
      await ref.read(appQuitProvider)();
    } on UpdateFailure catch (e) {
      _ready = null;
      state = e.kind == UpdateFailureKind.cancelled
          ? const UpdateTaskState()
          : UpdateTaskState(phase: UpdatePhase.failed, message: e.message);
    } on Object catch (e, stack) {
      _ready = null;
      _log.warning('Falha ao atualizar', e, stack);
      state = const UpdateTaskState(
        phase: UpdatePhase.failed,
        message:
            'Não foi possível atualizar. Sua versão continua funcionando; '
            'detalhes no log.',
      );
    } finally {
      _cancel = null;
    }
  }

  Future<PreparedUpdate> _prepared(ReleaseInfo release) async {
    final ready = _ready;
    if (ready != null && ready.release.version == release.version) return ready;
    state = const UpdateTaskState(phase: UpdatePhase.downloading);
    final cancel = _cancel = UpdateCancel();
    return ref
        .read(updateInstallerProvider)
        .prepare(
          release,
          cancel: cancel,
          onProgress: (received, total) {
            state = UpdateTaskState(
              phase: UpdatePhase.downloading,
              received: received,
              total: total,
            );
          },
        );
  }

  void cancel() => _cancel?.cancel();

  /// Baixa em segundo plano e deixa para instalar quando a janela fechar.
  /// Falhas ficam só no log: tenta de novo na próxima abertura.
  Future<void> prepareInBackground(ReleaseInfo release) async {
    if (state.busy || _ready != null) return;
    try {
      _ready = await ref.read(updateInstallerProvider).prepare(release);
    } on Object catch (e) {
      _log.info('Download em segundo plano falhou: $e');
      return;
    }
    if (_closeHookSet) return;
    _closeHookSet = true;
    await ref.read(beforeWindowClosesProvider)(_installOnClose);
  }

  Future<void> _installOnClose() async {
    final update = _ready;
    if (update == null) return;
    try {
      await ref.read(updateInstallerProvider).install(update, relaunch: false);
      await ref.read(appQuitProvider)();
    } on Object catch (e) {
      _log.warning('Não instalou ao fechar: $e');
    }
  }
}

/// Lê uma vez o resultado da atualização anterior.
class UpdateOutcomeNotifier extends AsyncNotifier<UpdateOutcome?> {
  @override
  Future<UpdateOutcome?> build() async {
    final snapshot = await ref.read(updateCheckerProvider).snapshot();
    return ref.read(updateInstallerProvider).takeOutcome(snapshot);
  }

  void dismiss() => state = const AsyncData(null);
}
