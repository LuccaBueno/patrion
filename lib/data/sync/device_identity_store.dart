import 'package:drift/drift.dart';

import '../../core/ids/id_generator.dart';
import '../../core/sync/hlc.dart';
import '../../core/time/instant_format.dart';
import '../db/app_database.dart';

/// Identidade deste PC: `device_id` e último HLC (`dev_identity`).
class DeviceIdentity {
  const DeviceIdentity({
    required this.deviceId,
    required this.deviceName,
    required this.lastHlc,
  });

  final String deviceId;
  final String deviceName;
  final Hlc lastHlc;
}

/// Lê ou cria a identidade do dispositivo.
///
/// O `device_id` é um UUID v7 gerado na primeira execução e fica só no banco
/// local (DECISIONS D-10).
class DeviceIdentityStore {
  const DeviceIdentityStore(this._db, {this._ids = const IdGenerator()});

  final AppDatabase _db;
  final IdGenerator _ids;

  Future<DeviceIdentity> loadOrCreate({
    required String deviceName,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final existing = await _db.select(_db.devIdentity).getSingleOrNull();
      if (existing != null) {
        return DeviceIdentity(
          deviceId: existing.deviceId,
          deviceName: existing.deviceName,
          lastHlc: Hlc.parse(existing.lastHlc),
        );
      }
      final deviceId = _ids.newId();
      final lastHlc = Hlc.zero(deviceId);
      await _db
          .into(_db.devIdentity)
          .insert(
            DevIdentityCompanion.insert(
              deviceId: deviceId,
              deviceName: deviceName,
              createdAt: formatInstant(now),
              lastHlc: lastHlc.toString(),
            ),
          );
      return DeviceIdentity(
        deviceId: deviceId,
        deviceName: deviceName,
        lastHlc: lastHlc,
      );
    });
  }

  /// Grava o último HLC. Chamado dentro da transação de cada escrita.
  Future<void> saveLastHlc(Hlc hlc) async {
    await (_db.update(_db.devIdentity)
          ..where((t) => t.deviceId.equals(hlc.deviceId)))
        .write(DevIdentityCompanion(lastHlc: Value(hlc.toString())));
  }
}
