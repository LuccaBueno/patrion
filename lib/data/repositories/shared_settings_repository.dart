import 'package:drift/drift.dart';

import '../../domain/settings/shared_setting.dart';
import '../db/app_database.dart';
import 'sync_repository.dart';

/// Configurações compartilhadas (`shared_settings`).
///
/// A chave natural `key` é aplicada aqui: gravar uma chave que já existe
/// altera o registro existente em vez de criar outro.
class SharedSettingsRepository
    extends SyncRepository<$SharedSettingsTable, SharedSettingRow> {
  SharedSettingsRepository(super.db, super.sync);

  @override
  $SharedSettingsTable get table => db.sharedSettings;

  Future<SharedSetting?> get(String key) async {
    final row = await _aliveByKey(key);
    return row == null ? null : _toEntity(row);
  }

  /// Grava [valueJson] em [key], criando ou alterando o registro.
  Future<String> put(String key, String valueJson) {
    return db.transaction(() async {
      final existing = await _aliveByKey(key);
      if (existing == null) {
        return insertRow(
          SharedSettingsCompanion(key: Value(key), valueJson: Value(valueJson)),
        );
      }
      if (existing.valueJson != valueJson) {
        await updateRow(
          existing.id,
          SharedSettingsCompanion(valueJson: Value(valueJson)),
        );
      }
      return existing.id;
    });
  }

  /// Exclui a configuração (tombstone). Não faz nada se ela não existir.
  Future<void> remove(String key) async {
    await db.transaction(() async {
      final existing = await _aliveByKey(key);
      if (existing != null) await softDelete(existing.id);
    });
  }

  Stream<List<SharedSetting>> watchAll() {
    final query = selectAlive()..orderBy([(t) => OrderingTerm.asc(t.key)]);
    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  /// Registro vivo da chave. Se a mesclagem tiver deixado mais de um (dois
  /// PCs criaram a mesma chave), vale o de maior HLC até a unificação (F5).
  Future<SharedSettingRow?> _aliveByKey(String key) {
    final query = selectAlive()
      ..where((t) => t.key.equals(key))
      ..orderBy([(t) => OrderingTerm.desc(t.hlc)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  SharedSetting _toEntity(SharedSettingRow row) =>
      SharedSetting(id: row.id, key: row.key, valueJson: row.valueJson);
}
