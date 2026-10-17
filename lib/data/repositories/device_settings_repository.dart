import 'package:clock/clock.dart';

import '../../core/time/instant_format.dart';
import '../db/app_database.dart';

/// Configurações só deste PC (`dev_settings`). Não são sincronizáveis e
/// nunca vão no save.
class DeviceSettingsRepository {
  const DeviceSettingsRepository(this._db, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final AppDatabase _db;
  final Clock _clock;

  Future<String?> get(String key) async {
    final row = await (_db.select(
      _db.devSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.valueJson;
  }

  Stream<String?> watch(String key) {
    final query = _db.select(_db.devSettings)..where((t) => t.key.equals(key));
    return query.watchSingleOrNull().map((row) => row?.valueJson);
  }

  Future<void> put(String key, String valueJson) async {
    await _db
        .into(_db.devSettings)
        .insertOnConflictUpdate(
          DevSettingsCompanion.insert(
            key: key,
            valueJson: valueJson,
            updatedAt: formatInstant(_clock.now()),
          ),
        );
  }
}
