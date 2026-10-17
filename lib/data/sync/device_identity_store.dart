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

  /// Depois de restaurar um backup, mantém a identidade deste PC: o banco
  /// restaurado pode ser de outro PC ou de antes de alterações já exportadas.
  /// O último HLC fica no maior entre o atual, o restaurado e [atLeast] (o
  /// maior HLC dos registros), para o relógio nunca voltar (DECISIONS D-28).
  Future<DeviceIdentity> adopt(
    DeviceIdentity identity, {
    required DateTime now,
    String? atLeast,
  }) {
    return _db.transaction(() async {
      final restored = await _db.select(_db.devIdentity).get();
      var last = identity.lastHlc;
      for (final candidate in [
        for (final r in restored) Hlc.parse(r.lastHlc),
        if (atLeast != null) Hlc.parse(atLeast),
      ]) {
        if (candidate.millis > last.millis ||
            (candidate.millis == last.millis &&
                candidate.counter > last.counter)) {
          last = Hlc(candidate.millis, candidate.counter, identity.deviceId);
        }
      }
      await _db.delete(_db.devIdentity).go();
      await _db
          .into(_db.devIdentity)
          .insert(
            DevIdentityCompanion.insert(
              deviceId: identity.deviceId,
              deviceName: identity.deviceName,
              createdAt: formatInstant(now),
              lastHlc: last.toString(),
            ),
          );
      return DeviceIdentity(
        deviceId: identity.deviceId,
        deviceName: identity.deviceName,
        lastHlc: last,
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
