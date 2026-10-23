import 'dart:convert';

import '../../data/repositories/device_settings_repository.dart';

/// Como a Carteira é mostrada neste PC (M-06): o filtro por corretora e o
/// agrupamento. Lembrados entre aberturas do app; não vão no save.
class PortfolioViewPreferences {
  const PortfolioViewPreferences(this._settings);

  static const brokerKey = 'portfolio.broker_filter';
  static const groupKey = 'portfolio.group_by_broker';

  final DeviceSettingsRepository _settings;

  /// Instituição escolhida no filtro; nulo = todas.
  Stream<String?> watchBroker() => _settings.watch(brokerKey).map((v) {
    if (v == null) return null;
    final decoded = jsonDecode(v);
    return decoded is String ? decoded : null;
  });

  Future<void> setBroker(String? institutionId) =>
      _settings.put(brokerKey, jsonEncode(institutionId));

  Stream<bool> watchGroup() =>
      _settings.watch(groupKey).map((v) => v != null && jsonDecode(v) == true);

  Future<void> setGroup(bool value) =>
      _settings.put(groupKey, jsonEncode(value));
}
