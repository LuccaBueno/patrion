import 'package:drift/drift.dart';

/// Campos de sincronização de toda tabela com dados do usuário
/// (CLAUDE.md e `docs/BANCO.md` §2).
///
/// Só o repositório base (`SyncRepository`) escreve nesses campos.
mixin SyncColumns on Table {
  /// UUID v7 gerado no app.
  TextColumn get id => text()();

  /// Instante UTC da criação (ISO-8601 com ms).
  TextColumn get createdAt => text()();

  /// Instante UTC da última escrita.
  TextColumn get updatedAt => text()();

  /// HLC da última alteração.
  TextColumn get hlc => text()();

  /// Dispositivo que fez a última alteração.
  TextColumn get deviceId => text()();

  /// Tombstone: preenchido na exclusão lógica.
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Dispositivo (dev_): nunca vão no save.
// ---------------------------------------------------------------------------

/// Identidade deste PC. Uma linha só.
@DataClassName('DevIdentityRow')
class DevIdentity extends Table {
  TextColumn get deviceId => text()();
  TextColumn get deviceName => text()();
  TextColumn get createdAt => text()();

  /// Último HLC emitido ou recebido, para o relógio continuar crescendo
  /// depois de reiniciar o app.
  TextColumn get lastHlc => text()();

  @override
  Set<Column<Object>> get primaryKey => {deviceId};
}

/// Configurações só deste PC (tema, tamanho da janela, pastas usadas).
@DataClassName('DevSettingRow')
class DevSettings extends Table {
  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

// ---------------------------------------------------------------------------
// Configurações compartilhadas (sincronizáveis).
// ---------------------------------------------------------------------------

/// Preferências que valem em todos os PCs. Chave natural: `key`, aplicada
/// pelo app (não por índice único, ver `docs/BANCO.md` §2).
@DataClassName('SharedSettingRow')
@TableIndex(name: 'shared_settings_hlc', columns: {#hlc})
@TableIndex(name: 'shared_settings_key', columns: {#key})
class SharedSettings extends Table with SyncColumns {
  TextColumn get key => text()();
  TextColumn get valueJson => text()();
}
