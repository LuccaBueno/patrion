import 'dart:convert';

import '../../data/repositories/device_settings_repository.dart';

/// Preferências de dados de mercado deste PC (SPEC §5; DECISIONS D-05).
class MarketPreferences {
  const MarketPreferences(this._settings);

  static const refreshKey = 'market.refresh_minutes';
  static const startYearKey = 'market.history_start_year';

  /// Atualização automática a cada 30 minutos (0 = desligada).
  static const defaultRefreshMinutes = 30;
  static const refreshOptions = [15, 30, 60, 240, 0];

  final DeviceSettingsRepository _settings;

  Stream<int> watchRefreshMinutes() =>
      _settings.watch(refreshKey).map((v) => _int(v) ?? defaultRefreshMinutes);

  Future<int> refreshMinutes() async =>
      _int(await _settings.get(refreshKey)) ?? defaultRefreshMinutes;

  Future<void> setRefreshMinutes(int minutes) =>
      _settings.put(refreshKey, jsonEncode(minutes));

  /// Ano inicial do histórico (COTAHIST, indicadores, câmbio). Padrão:
  /// dez anos antes de [currentYear] (M-08; era cinco até a 1.1.0).
  Future<int> historyStartYear(int currentYear) async =>
      _int(await _settings.get(startYearKey)) ?? defaultStartYear(currentYear);

  static int defaultStartYear(int currentYear) => currentYear - 10;

  Stream<int?> watchHistoryStartYear() =>
      _settings.watch(startYearKey).map(_int);

  Future<void> setHistoryStartYear(int year) =>
      _settings.put(startYearKey, jsonEncode(year));

  static int? _int(String? json) {
    if (json == null) return null;
    try {
      final v = jsonDecode(json);
      return v is int && v >= 0 ? v : null;
    } on FormatException {
      return null;
    }
  }
}
