import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:logging/logging.dart';

import '../../core/errors/app_error.dart';
import '../../core/sync/hlc.dart';
import '../../core/time/instant_format.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/sync_peers_repository.dart';
import '../../data/sync/sync_context.dart';
import '../../data/sync/sync_tables_gateway.dart';
import '../../domain/backup/backup_metadata.dart';
import '../../domain/sync/invsave_codec.dart';
import '../../domain/sync/merge_planner.dart';
import '../../domain/sync/save_contents.dart';
import '../../domain/sync/save_manifest.dart';
import '../../domain/sync/sync_rows.dart';
import '../backup/backup_service.dart';

final _log = Logger('save');

/// Save pronto para gravar.
class SaveExport {
  const SaveExport({
    required this.bytes,
    required this.manifest,
    required this.suggestedFileName,
  });

  final Uint8List bytes;
  final SaveManifest manifest;

  /// `Patrion_<NomeDoPC>_<AAAA-MM-DD_HHmm>.invsave` (SPEC §10.2).
  final String suggestedFileName;

  int get totalRecords => manifest.counts.values.fold(0, (a, b) => a + b);
}

/// Save lido e validado, com a prévia da mesclagem (valores padrão nos
/// conflitos).
class ImportPreview {
  const ImportPreview({
    required this.fileName,
    required this.manifest,
    required this.tables,
    required this.schemas,
    required this.plan,
    required this.fromThisDevice,
  });

  final String fileName;
  final SaveManifest manifest;

  /// Registros já convertidos para o schema atual.
  final Map<String, List<SyncRow>> tables;

  /// Tabelas sincronizáveis do banco (para mostrar as diferenças).
  final Map<String, SyncTableSchema> schemas;
  final MergePlan plan;

  /// O save foi gerado por este mesmo PC.
  final bool fromThisDevice;

  bool get upgradedFromOlderSchema =>
      manifest.schemaVersion < AppDatabase.latestSchemaVersion;
}

/// Resultado de uma importação aplicada.
class ImportResult {
  const ImportResult({required this.plan, required this.backup});

  final MergePlan plan;

  /// Backup automático feito antes de alterar o banco.
  final DevBackupRow backup;
}

/// Arquivo de save: exportar e importar mesclando (SPEC §10.2 a §10.5).
///
/// O save é sempre um snapshot completo de todas as tabelas sincronizáveis,
/// inclusive tombstones. Dados derivados, logs, configurações do dispositivo
/// (`dev_`) e chaves de API nunca vão nele.
class SaveService {
  SaveService({
    required this._tables,
    required this._peers,
    required this._sync,
    required this._backups,
    required this.appVersion,
    required this.deviceName,
    Clock wallClock = const Clock(),
    this.beforeWrite,
  }) : _clock = wallClock;

  final SyncTablesGateway _tables;
  final SyncPeersRepository _peers;
  final SyncContext _sync;
  final BackupService _backups;
  final Clock _clock;
  final String appVersion;
  final String deviceName;

  /// Só para testes: chamado antes de cada escrita da importação (para
  /// simular uma falha no meio).
  final void Function(int index)? beforeWrite;

  // -- Exportar ---------------------------------------------------------------

  Future<SaveExport> buildExport() async {
    final schemas = await _tables.schemas();
    final data = await _tables.readAll(schemas);
    String? maxHlc;
    for (final rows in data.values) {
      for (final r in rows) {
        if (maxHlc == null || r.hlc.compareTo(maxHlc) > 0) maxHlc = r.hlc;
      }
    }
    final now = _clock.now();
    final manifest = SaveManifest(
      appVersion: appVersion,
      schemaVersion: AppDatabase.latestSchemaVersion,
      deviceId: _sync.deviceId,
      deviceName: deviceName,
      createdAt: formatInstant(now),
      maxHlc: maxHlc,
      counts: {for (final e in data.entries) e.key: e.value.length},
      knownPeers: [
        for (final p in await _peers.peers())
          if (p.lastHlcReceived.isNotEmpty)
            KnownPeer(
              deviceId: p.peerDeviceId,
              lastHlcReceived: p.lastHlcReceived,
            ),
      ],
    );
    final bytes = InvsaveCodec.encode(manifest, data);
    return SaveExport(
      bytes: bytes,
      manifest: InvsaveCodec.decode(bytes).manifest,
      suggestedFileName: suggestedFileName(deviceName, now.toLocal()),
    );
  }

  /// Registra no histórico um save gravado em [fileName].
  Future<void> recordExport(SaveExport export, String fileName) async {
    await _peers.addHistory(
      direction: 'export',
      fileName: fileName,
      at: formatInstant(_clock.now()),
      counts: export.manifest.counts,
      result: 'ok',
      maxHlc: export.manifest.maxHlc,
    );
    _log.info('Save exportado (${export.totalRecords} registros)');
  }

  static String suggestedFileName(String deviceName, DateTime local) {
    String two(int v) => v.toString().padLeft(2, '0');
    final name = deviceName.replaceAll(RegExp(r'[^A-Za-z0-9-]+'), '-');
    return 'Patrion_${name}_${local.year}-${two(local.month)}-'
        '${two(local.day)}_${two(local.hour)}${two(local.minute)}'
        '.${InvsaveCodec.extension}';
  }

  // -- Importar ---------------------------------------------------------------

  /// Valida o arquivo (ZIP, manifesto, checksums, formato e schema) e
  /// calcula a prévia. Não altera nada. Lança [DataError] se o arquivo for
  /// recusado.
  Future<ImportPreview> preview(
    Uint8List bytes, {
    required String fileName,
  }) async {
    final package = InvsaveCodec.decode(bytes);
    final manifest = package.manifest;
    if (manifest.schemaVersion > AppDatabase.latestSchemaVersion) {
      throw DataError(
        'Este save foi gerado por uma versão mais nova do Patrion (schema '
        '${manifest.schemaVersion}; esta versão conhece até o '
        '${AppDatabase.latestSchemaVersion}). Atualize o aplicativo para '
        'importá-lo.',
      );
    }
    final schemas = await _tables.schemas();
    final tables = SaveContents.upgrade(
      package.tables,
      from: manifest.schemaVersion,
      to: AppDatabase.latestSchemaVersion,
    );
    SaveContents.validate(tables, schemas);
    final plan = await _plan(manifest, tables, schemas, const {});
    return ImportPreview(
      fileName: fileName,
      manifest: manifest,
      tables: tables,
      schemas: schemas,
      plan: plan,
      fromThisDevice: manifest.deviceId == _sync.deviceId,
    );
  }

  /// Aplica a importação: backup automático, depois mesclagem numa única
  /// transação (recalculada com o banco de agora e as escolhas dos
  /// conflitos). Se algo falhar, nada é alterado.
  Future<ImportResult> apply(
    ImportPreview preview, {
    Map<RowRef, MergeSide> resolutions = const {},
  }) async {
    final backup = await _backups.createAutomatic(BackupReason.preImport);
    final manifest = preview.manifest;
    try {
      final plan = await _tables.transaction(() async {
        final schemas = await _tables.schemas();
        final plan = await _plan(
          manifest,
          preview.tables,
          schemas,
          resolutions,
        );
        if (plan.maxIncomingHlc != null) {
          await _sync.receive(Hlc.parse(plan.maxIncomingHlc!));
        }
        await _tables.apply(plan, schemas, beforeWrite: beforeWrite);
        if (!preview.fromThisDevice) {
          await _peers.recordImport(
            deviceId: manifest.deviceId,
            deviceName: manifest.deviceName,
            maxHlc: manifest.maxHlc,
            knownHlcOfThisDevice: manifest.knownHlcOf(_sync.deviceId),
            at: formatInstant(_clock.now()),
          );
        }
        return plan;
      });
      await _peers.addHistory(
        direction: 'import',
        fileName: preview.fileName,
        at: formatInstant(_clock.now()),
        counts: _countsOf(plan),
        result: 'ok',
        peerDeviceId: manifest.deviceId,
        peerName: manifest.deviceName,
        maxHlc: manifest.maxHlc,
      );
      _log.info(
        'Save importado: ${plan.totalChanges} alterações, '
        '${plan.conflicts.length} conflitos, '
        '${plan.unifications.length} unificações',
      );
      return ImportResult(plan: plan, backup: backup);
    } catch (error, stack) {
      _log.severe('Importação do save falhou; nada foi alterado', error, stack);
      await _peers.addHistory(
        direction: 'import',
        fileName: preview.fileName,
        at: formatInstant(_clock.now()),
        counts: const {},
        result: 'failed',
        peerDeviceId: manifest.deviceId,
        peerName: manifest.deviceName,
        maxHlc: manifest.maxHlc,
        message: error is AppError ? error.message : 'erro interno',
      );
      if (error is AppError) rethrow;
      throw InternalError(
        'A importação falhou e foi desfeita. Nada foi alterado.',
        cause: error,
      );
    }
  }

  Future<MergePlan> _plan(
    SaveManifest manifest,
    Map<String, List<SyncRow>> incoming,
    Map<String, SyncTableSchema> schemas,
    Map<RowRef, MergeSide> resolutions,
  ) async {
    final local = await _tables.readAll(schemas);
    final MergeContext context;
    if (manifest.deviceId == _sync.deviceId) {
      // Save deste próprio PC: tudo nele já foi visto aqui.
      context = MergeContext(
        peerKnowsLocalUpTo: manifest.maxHlc,
        localKnowsPeerUpTo: manifest.maxHlc,
      );
    } else {
      final peer = await _peers.peer(manifest.deviceId);
      context = MergeContext(
        peerKnowsLocalUpTo: _max(
          peer?.lastHlcSent,
          manifest.knownHlcOf(_sync.deviceId),
        ),
        localKnowsPeerUpTo: peer?.lastHlcReceived,
      );
    }
    return MergePlanner(schemas.values).plan(
      local: local,
      incoming: incoming,
      context: context,
      resolutions: resolutions,
      newId: _sync.newId,
      now: formatInstant(_clock.now()),
    );
  }

  static Map<String, Object?> _countsOf(MergePlan plan) => {
    for (final e in plan.changes.entries) e.key: e.value.toJson(),
    'conflicts': plan.conflicts.length,
    'unifications': plan.unifications.length,
    'duplicates': plan.duplicates.length,
  };

  static String? _max(String? a, String? b) {
    if (a == null || a.isEmpty) return b;
    if (b == null || b.isEmpty) return a;
    return a.compareTo(b) >= 0 ? a : b;
  }
}
