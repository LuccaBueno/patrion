import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:patrion/data/db/app_database.dart';
import 'package:patrion/data/sync/device_identity_store.dart';
import 'package:patrion/data/sync/sync_context.dart';

/// Relógio de parede que o teste pode mover (inclusive para trás).
class MutableClock {
  MutableClock(this.now);

  DateTime now;

  Clock get clock => Clock(() => now);

  void advance(Duration d) => now = now.add(d);
}

/// Banco em memória com identidade do dispositivo e contexto de sync.
class TestDb {
  TestDb._(this.db, this.identity, this.sync, this.wall);

  static Future<TestDb> open({
    DateTime? start,
    String deviceName = 'PC-TESTE',
    QueryExecutor? executor,
  }) async {
    final wall = MutableClock(start ?? DateTime.utc(2026, 10, 17, 12));
    final db = executor == null ? AppDatabase.memory() : AppDatabase(executor);
    final store = DeviceIdentityStore(db);
    final identity = await store.loadOrCreate(
      deviceName: deviceName,
      now: wall.now,
    );
    final sync = SyncContext(
      identity: identity,
      store: store,
      wallClock: wall.clock,
    );
    return TestDb._(db, identity, sync, wall);
  }

  final AppDatabase db;
  final DeviceIdentity identity;
  final SyncContext sync;
  final MutableClock wall;

  Future<void> close() => db.close();
}
