import 'dart:convert';

import '../../data/repositories/shared_settings_repository.dart';

/// Preferências da carteira que valem em todos os PCs e vão no save
/// (`shared_settings`).
class PortfolioPreferences {
  const PortfolioPreferences(this._settings);

  /// Controle do saldo em caixa (M-03; DECISIONS D-44).
  static const trackCashKey = 'portfolio.track_cash';

  /// Desligado por padrão: quem só acompanha os ativos da corretora não vê
  /// caixa nem patrimônio negativos por não registrar depósitos.
  static const defaultTrackCash = false;

  final SharedSettingsRepository _settings;

  Future<bool> trackCash() async =>
      _bool((await _settings.get(trackCashKey))?.valueJson) ?? defaultTrackCash;

  Stream<bool> watchTrackCash() => _settings.watchAll().map(
    (all) =>
        _bool(all.where((s) => s.key == trackCashKey).firstOrNull?.valueJson) ??
        defaultTrackCash,
  );

  Future<void> setTrackCash(bool value) =>
      _settings.put(trackCashKey, jsonEncode(value));

  static bool? _bool(String? json) {
    if (json == null) return null;
    final value = jsonDecode(json);
    return value is bool ? value : null;
  }
}
