import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings/lock_preferences.dart';
import '../providers.dart';

/// Bloqueio por inatividade (SPEC §3): sem mouse nem teclado por
/// `lock.idle_minutes` minutos (padrão 15; 0 = nunca), chama [onIdle].
///
/// Fica acima do `MaterialApp`, então vê também os eventos dos diálogos.
class InactivityGuard extends ConsumerStatefulWidget {
  const InactivityGuard({
    required this.enabled,
    required this.onIdle,
    required this.child,
    super.key,
  });

  /// Só com o bloqueio ativo: sem senha não há o que bloquear.
  final bool enabled;
  final Future<void> Function() onIdle;
  final Widget child;

  @override
  ConsumerState<InactivityGuard> createState() => _InactivityGuardState();
}

class _InactivityGuardState extends ConsumerState<InactivityGuard> {
  Timer? _timer;
  Duration? _timeout;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _timer?.cancel();
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    _restart();
    return false;
  }

  void _restart() {
    _timer?.cancel();
    final timeout = _timeout;
    if (!widget.enabled || timeout == null) return;
    _timer = Timer(timeout, () {
      if (mounted) widget.onIdle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes =
        ref.watch(idleMinutesProvider).value ??
        LockPreferences.defaultIdleMinutes;
    final timeout = minutes == 0 ? null : Duration(minutes: minutes);
    if (timeout != _timeout || (_timer == null && timeout != null)) {
      _timeout = timeout;
      _restart();
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restart(),
      onPointerHover: (_) => _restart(),
      onPointerMove: (_) => _restart(),
      onPointerSignal: (_) => _restart(),
      child: widget.child,
    );
  }
}
