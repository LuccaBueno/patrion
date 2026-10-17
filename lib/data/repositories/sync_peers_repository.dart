import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/ids/id_generator.dart';
import '../db/app_database.dart';

/// Dispositivos com quem este PC já trocou saves (`dev_sync_peers`) e o
/// histórico de sincronizações (`dev_sync_history`). Só deste PC: nunca vão
/// no save.
class SyncPeersRepository {
  const SyncPeersRepository(this._db, {this._ids = const IdGenerator()});

  final AppDatabase _db;
  final IdGenerator _ids;

  Future<DevSyncPeerRow?> peer(String deviceId) => (_db.select(
    _db.devSyncPeers,
  )..where((t) => t.peerDeviceId.equals(deviceId))).getSingleOrNull();

  Future<List<DevSyncPeerRow>> peers() => _peersQuery().get();

  Stream<List<DevSyncPeerRow>> watchPeers() => _peersQuery().watch();

  SimpleSelectStatement<$DevSyncPeersTable, DevSyncPeerRow> _peersQuery() =>
      _db.select(_db.devSyncPeers)
        ..orderBy([(t) => OrderingTerm.desc(t.lastSyncAt)]);

  /// Registra a importação de um save de [deviceId]. Os HLCs só avançam:
  /// importar um save antigo não faz o PC "esquecer" o que já recebeu.
  Future<void> recordImport({
    required String deviceId,
    required String deviceName,
    required String? maxHlc,
    required String? knownHlcOfThisDevice,
    required String at,
  }) async {
    final previous = await peer(deviceId);
    await _db
        .into(_db.devSyncPeers)
        .insertOnConflictUpdate(
          DevSyncPeersCompanion.insert(
            peerDeviceId: deviceId,
            peerName: deviceName,
            lastHlcReceived:
                _max(previous?.lastHlcReceived, maxHlc) ??
                previous?.lastHlcReceived ??
                '',
            lastHlcSent: Value(
              _max(previous?.lastHlcSent, knownHlcOfThisDevice),
            ),
            lastSyncAt: at,
          ),
        );
  }

  Future<void> addHistory({
    required String direction,
    required String fileName,
    required String at,
    required Map<String, Object?> counts,
    required String result,
    String? peerDeviceId,
    String? peerName,
    String? maxHlc,
    String? message,
  }) async {
    await _db
        .into(_db.devSyncHistory)
        .insert(
          DevSyncHistoryCompanion.insert(
            id: _ids.newId(),
            direction: direction,
            peerDeviceId: Value(peerDeviceId),
            peerName: Value(peerName),
            fileName: fileName,
            at: at,
            maxHlc: Value(maxHlc),
            countsJson: jsonEncode(counts),
            result: result,
            message: Value(message),
          ),
        );
  }

  Stream<List<DevSyncHistoryRow>> watchHistory({int limit = 50}) =>
      (_db.select(_db.devSyncHistory)
            ..orderBy([(t) => OrderingTerm.desc(t.at)])
            ..limit(limit))
          .watch();

  static String? _max(String? a, String? b) {
    if (a == null || a.isEmpty) return b;
    if (b == null || b.isEmpty) return a;
    return a.compareTo(b) >= 0 ? a : b;
  }
}
