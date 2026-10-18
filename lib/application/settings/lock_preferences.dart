import 'dart:convert';

import '../../data/repositories/device_settings_repository.dart';

/// Tempo sem uso até o app se bloquear sozinho (SPEC §3). Configuração deste
/// PC, guardada no próprio banco (só vale com o banco aberto).
class LockPreferences {
  const LockPreferences(this._settings);

  static const idleKey = 'lock.idle_minutes';

  /// Padrão da SPEC: 15 minutos.
  static const defaultIdleMinutes = 15;

  /// Opções da tela; 0 é "nunca".
  static const idleOptions = [1, 5, 15, 30, 60, 0];

  final DeviceSettingsRepository _settings;

  Stream<int> watchIdleMinutes() => _settings.watch(idleKey).map(_decode);

  Future<void> setIdleMinutes(int minutes) =>
      _settings.put(idleKey, jsonEncode(minutes));

  /// Valor ausente ou inválido volta ao padrão.
  static int _decode(String? json) {
    if (json == null) return defaultIdleMinutes;
    try {
      final value = jsonDecode(json);
      return value is int && value >= 0 ? value : defaultIdleMinutes;
    } on FormatException {
      return defaultIdleMinutes;
    }
  }
}
