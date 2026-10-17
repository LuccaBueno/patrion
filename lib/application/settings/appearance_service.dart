import 'dart:convert';

import '../../data/repositories/device_settings_repository.dart';

/// Tema escolhido pelo usuário. É configuração deste PC (SPEC §10.1).
enum ThemePreference {
  system('Seguir o Windows'),
  light('Claro'),
  dark('Escuro');

  const ThemePreference(this.label);

  final String label;
}

/// Lê e grava as preferências de aparência deste PC.
class AppearanceService {
  const AppearanceService(this._settings);

  static const themeKey = 'theme';

  final DeviceSettingsRepository _settings;

  Stream<ThemePreference> watchTheme() =>
      _settings.watch(themeKey).map(_decode);

  Future<ThemePreference> theme() async =>
      _decode(await _settings.get(themeKey));

  Future<void> setTheme(ThemePreference value) =>
      _settings.put(themeKey, jsonEncode(value.name));

  /// Valor ausente ou desconhecido (de uma versão futura) volta ao padrão.
  static ThemePreference _decode(String? json) {
    if (json == null) return ThemePreference.system;
    final Object? name;
    try {
      name = jsonDecode(json);
    } on FormatException {
      return ThemePreference.system;
    }
    return ThemePreference.values.firstWhere(
      (v) => v.name == name,
      orElse: () => ThemePreference.system,
    );
  }
}
