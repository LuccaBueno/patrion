import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../../core/errors/app_error.dart';
import 'save_manifest.dart';
import 'sync_rows.dart';

/// Conteúdo de um arquivo de save já validado.
class SavePackage {
  const SavePackage({required this.manifest, required this.tables});

  final SaveManifest manifest;

  /// Registros por tabela, como estão no arquivo (schema do manifesto).
  final Map<String, List<SyncRow>> tables;
}

/// Lê e grava o arquivo `.invsave` (SPEC §10.1, `docs/SINCRONIZACAO.md`).
///
/// ```
/// manifest.json          manifesto (versões, dispositivo, contagens, SHA-256)
/// manifest.sha256        SHA-256 do manifest.json
/// data/<tabela>.jsonl    um registro por linha, inclusive tombstones
/// ```
///
/// Na leitura, qualquer divergência (ZIP ilegível, checksum, contagem, HLC
/// máximo, arquivo não declarado) recusa o arquivo inteiro com [DataError],
/// antes de qualquer alteração no banco.
abstract final class InvsaveCodec {
  static const extension = 'invsave';
  static const manifestPath = 'manifest.json';
  static const manifestChecksumPath = 'manifest.sha256';
  static const dataDir = 'data';

  static String dataPath(String table) => '$dataDir/$table.jsonl';

  static String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

  /// Gera o arquivo. Preenche `files` do manifesto com o SHA-256 de cada
  /// tabela; [manifest] traz o resto.
  static Uint8List encode(
    SaveManifest manifest,
    Map<String, List<SyncRow>> tables,
  ) {
    final archive = Archive();
    final files = <String, String>{};
    for (final table in tables.keys.toList()..sort()) {
      final buffer = StringBuffer();
      for (final row in tables[table]!) {
        buffer
          ..write(jsonEncode(row))
          ..write('\n');
      }
      final bytes = utf8.encode(buffer.toString());
      final path = dataPath(table);
      files[path] = sha256Hex(bytes);
      archive.addFile(ArchiveFile.bytes(path, bytes));
    }
    final manifestBytes = utf8.encode(
      const JsonEncoder.withIndent('  ')
          .convert(manifest.copyWith(files: files).toJson()),
    );
    archive
      ..addFile(ArchiveFile.bytes(manifestPath, manifestBytes))
      ..addFile(
        ArchiveFile.string(manifestChecksumPath, sha256Hex(manifestBytes)),
      );
    return ZipEncoder().encodeBytes(archive);
  }

  /// Lê e valida o arquivo.
  static SavePackage decode(List<int> bytes) {
    Never corrupt(String detail) => throw DataError(
      'O arquivo de save está corrompido ou foi alterado ($detail). Nada foi '
      'importado.',
    );

    final Map<String, Uint8List> entries;
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      entries = {
        for (final f in archive.files)
          if (f.isFile) f.name: f.readBytes() ?? Uint8List(0),
      };
    } catch (_) {
      throw const DataError(
        'O arquivo não é um save do Patrion ou está corrompido (ZIP '
        'ilegível). Nada foi importado.',
      );
    }

    final manifestBytes = entries[manifestPath];
    final manifestSum = entries[manifestChecksumPath];
    if (manifestBytes == null || manifestSum == null) {
      throw const DataError(
        'O arquivo não é um save do Patrion (sem manifesto). Nada foi '
        'importado.',
      );
    }
    if (_ascii(manifestSum).trim() != sha256Hex(manifestBytes)) {
      corrupt('checksum do manifesto');
    }
    final SaveManifest manifest;
    try {
      manifest = SaveManifest.fromJson(jsonDecode(utf8.decode(manifestBytes)));
    } on FormatException {
      corrupt('manifesto ilegível');
    }
    if (manifest.encryption != SaveManifest.encryptionNone) {
      throw const DataError(
        'Este save está protegido por senha, o que esta versão do Patrion '
        'ainda não abre.',
      );
    }

    for (final name in entries.keys) {
      if (name == manifestPath || name == manifestChecksumPath) continue;
      if (!manifest.files.containsKey(name)) corrupt('arquivo não declarado');
    }

    final tables = <String, List<SyncRow>>{};
    String? maxHlc;
    for (final MapEntry(key: path, value: expectedSum)
        in manifest.files.entries) {
      final content = entries[path];
      if (content == null) corrupt('arquivo ausente');
      if (sha256Hex(content) != expectedSum) corrupt('checksum de $path');
      final match = RegExp(r'^data/([a-z0-9_]+)\.jsonl$').firstMatch(path);
      if (match == null) corrupt('caminho inesperado');
      final table = match.group(1)!;
      final rows = <SyncRow>[];
      try {
        for (final line in const LineSplitter().convert(utf8.decode(content))) {
          if (line.isEmpty) continue;
          final row = _row(jsonDecode(line));
          if (row == null) corrupt('registro inválido em $table');
          final hlc = row['hlc'];
          if (hlc != null && (maxHlc == null || hlc.compareTo(maxHlc) > 0)) {
            maxHlc = hlc;
          }
          rows.add(row);
        }
      } on FormatException {
        corrupt('registro ilegível em $table');
      }
      if (manifest.counts[table] != rows.length) corrupt('contagem de $table');
      tables[table] = rows;
    }
    for (final table in manifest.counts.keys) {
      if (!tables.containsKey(table)) corrupt('tabela $table ausente');
    }
    if (maxHlc != manifest.maxHlc) corrupt('HLC máximo');

    return SavePackage(manifest: manifest, tables: tables);
  }

  static SyncRow? _row(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final row = <String, String?>{};
    for (final MapEntry(:key, :value) in json.entries) {
      if (value != null && value is! String) return null;
      row[key] = value as String?;
    }
    return row;
  }

  static String _ascii(List<int> bytes) =>
      String.fromCharCodes(bytes.where((b) => b < 128));
}
