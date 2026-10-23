import 'dart:convert';

import 'package:decimal/decimal.dart';

import '../../data/repositories/shared_settings_repository.dart';
import '../../domain/portfolio/codes.dart';

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

  /// Alocação-alvo por classe (F8): `{"stock_br": "0.4", ...}`, frações em
  /// texto (sem ponto flutuante).
  static const targetsKey = 'portfolio.allocation_targets';

  Stream<Map<AssetClass, Decimal>> watchTargets() => _settings.watchAll().map(
    (all) =>
        _targets(all.where((s) => s.key == targetsKey).firstOrNull?.valueJson),
  );

  /// Grava os alvos (sem os zerados); vazio apaga.
  Future<void> setTargets(Map<AssetClass, Decimal> targets) {
    final kept = {
      for (final MapEntry(:key, :value) in targets.entries)
        if (value > Decimal.zero) key.code: value.toString(),
    };
    return kept.isEmpty
        ? _settings.remove(targetsKey)
        : _settings.put(targetsKey, jsonEncode(kept));
  }

  static Map<AssetClass, Decimal> _targets(String? json) {
    if (json == null) return const {};
    final value = jsonDecode(json);
    if (value is! Map<String, Object?>) return const {};
    return {
      for (final MapEntry(:key, :value) in value.entries)
        if (AssetClass.values.where((c) => c.code == key).firstOrNull
            case final c?)
          if (value is String) c: ?Decimal.tryParse(value),
    };
  }

  static bool? _bool(String? json) {
    if (json == null) return null;
    final value = jsonDecode(json);
    return value is bool ? value : null;
  }
}
