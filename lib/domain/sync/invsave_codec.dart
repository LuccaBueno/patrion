import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../../core/crypto/crypto_box.dart';
import '../../core/errors/app_error.dart';
import 'save_manifest.dart';
import 'sync_rows.dart';

/// Registros de mercado por tabela `mkt_`: coluna → valor em texto.
typedef MarketRows = Map<String, List<Map<String, String?>>>;

/// Conteúdo de um arquivo de save já validado.
class SavePackage {
  const SavePackage({
    required this.manifest,
    required this.tables,
    this.market = const {},
  });

  final SaveManifest manifest;

  /// Registros por tabela, como estão no arquivo (schema do manifesto).
  final Map<String, List<SyncRow>> tables;

  /// Dados de mercado (pasta `market/`), se incluídos.
  final MarketRows market;
}

/// Lê e grava o arquivo `.invsave` (SPEC §10.1, `docs/SINCRONIZACAO.md`).
///
/// ```
/// manifest.json          manifesto (versões, dispositivo, contagens, SHA-256)
/// manifest.sha256        SHA-256 do manifest.json
/// data/<tabela>.jsonl    um registro por linha, inclusive tombstones
/// market/<tabela>.jsonl  dados de mercado (opcional, formato 2)
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
  static const marketDir = 'market';
  static const payloadPath = 'payload.bin';
  static final _payloadAad = Uint8List.fromList(
    utf8.encode('patrion-invsave-payload/v1'),
  );

  static String dataPath(String table) => '$dataDir/$table.jsonl';

  static String marketPath(String table) => '$marketDir/$table.jsonl';

  static String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

  /// Gera o arquivo. Preenche `files` do manifesto com o SHA-256 de cada
  /// tabela; [manifest] traz o resto. Com [market], inclui a pasta
  /// `market/` (formato 2).
  static Uint8List encode(
    SaveManifest manifest,
    Map<String, List<SyncRow>> tables, {
    MarketRows? market,
  }) {
    final archive = Archive();
    final files = <String, String>{};
    if (market != null) {
      for (final table in market.keys.toList()..sort()) {
        final buffer = StringBuffer();
        for (final row in market[table]!) {
          buffer
            ..write(jsonEncode(row))
            ..write('\n');
        }
        final bytes = utf8.encode(buffer.toString());
        final path = marketPath(table);
        files[path] = sha256Hex(bytes);
        archive.addFile(ArchiveFile.bytes(path, bytes));
      }
    }
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
      const JsonEncoder.withIndent('  ').convert(
        manifest
            .copyWith(
              files: files,
              marketIncluded: market != null,
              marketCounts: {
                for (final e in (market ?? const {}).entries)
                  e.key: e.value.length,
              },
              formatVersion: market == null
                  ? SaveManifest.formatWithoutMarket
                  : SaveManifest.currentFormatVersion,
            )
            .toJson(),
      ),
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
    final entries = _entries(bytes);
    final manifest = _manifest(entries);
    if (manifest.encryption != SaveManifest.encryptionNone) {
      throw const DataError(
        'Este save está protegido por senha. Digite a senha do arquivo para '
        'importá-lo.',
      );
    }

    for (final name in entries.keys) {
      if (name == manifestPath || name == manifestChecksumPath) continue;
      if (!manifest.files.containsKey(name)) _corrupt('arquivo não declarado');
    }

    final tables = <String, List<SyncRow>>{};
    final market = <String, List<Map<String, String?>>>{};
    String? maxHlc;
    for (final MapEntry(key: path, value: expectedSum)
        in manifest.files.entries) {
      final content = entries[path];
      if (content == null) _corrupt('arquivo ausente');
      if (sha256Hex(content) != expectedSum) _corrupt('checksum de $path');
      final marketMatch = RegExp(r'^market/(mkt_[a-z0-9_]+)\.jsonl$')
          .firstMatch(path);
      if (marketMatch != null) {
        if (!manifest.marketIncluded) {
          _corrupt('dados de mercado não declarados');
        }
        final table = marketMatch.group(1)!;
        market[table] = _marketRows(content, table);
        if (manifest.marketCounts[table] != market[table]!.length) {
          _corrupt('contagem de $table');
        }
        continue;
      }
      final match = RegExp(r'^data/([a-z0-9_]+)\.jsonl$').firstMatch(path);
      if (match == null) _corrupt('caminho inesperado');
      final table = match.group(1)!;
      final rows = <SyncRow>[];
      try {
        for (final line in const LineSplitter().convert(utf8.decode(content))) {
          if (line.isEmpty) continue;
          final row = _row(jsonDecode(line));
          if (row == null) _corrupt('registro inválido em $table');
          final hlc = row['hlc'];
          if (hlc != null && (maxHlc == null || hlc.compareTo(maxHlc) > 0)) {
            maxHlc = hlc;
          }
          rows.add(row);
        }
      } on FormatException {
        _corrupt('registro ilegível em $table');
      }
      if (manifest.counts[table] != rows.length) _corrupt('contagem de $table');
      tables[table] = rows;
    }
    for (final table in manifest.counts.keys) {
      if (!tables.containsKey(table)) _corrupt('tabela $table ausente');
    }
    for (final table in manifest.marketCounts.keys) {
      if (!market.containsKey(table)) _corrupt('tabela $table ausente');
    }
    if (maxHlc != manifest.maxHlc) _corrupt('HLC máximo');

    return SavePackage(manifest: manifest, tables: tables, market: market);
  }

  static List<Map<String, String?>> _marketRows(
    List<int> content,
    String table,
  ) {
    final rows = <Map<String, String?>>[];
    try {
      for (final line in const LineSplitter().convert(utf8.decode(content))) {
        if (line.isEmpty) continue;
        final json = jsonDecode(line);
        if (json is! Map<String, Object?>) {
          _corrupt('registro inválido em $table');
        }
        final row = <String, String?>{};
        for (final MapEntry(:key, :value) in json.entries) {
          if (value != null && value is! String) {
            _corrupt('registro inválido em $table');
          }
          row[key] = value as String?;
        }
        rows.add(row);
      }
    } on FormatException {
      _corrupt('registro ilegível em $table');
    }
    return rows;
  }

  /// Manifesto do arquivo, sem conferir o conteúdo: diz se ele é protegido
  /// por senha e de que PC veio. Lança [DataError] se não for um save.
  static SaveManifest readManifest(List<int> bytes) =>
      _manifest(_entries(bytes));

  static bool isProtected(List<int> bytes) =>
      readManifest(bytes).encryption != SaveManifest.encryptionNone;

  /// Protege o save [save] com [password] (SPEC §10.6, DECISIONS D-32): o
  /// arquivo inteiro vai cifrado com AES-256-GCM em `payload.bin`, com chave
  /// Argon2id. O manifesto de fora diz só a versão, o PC de origem, a data e
  /// os parâmetros da criptografia.
  static Future<Uint8List> protect(
    Uint8List save,
    String password, {
    KdfPolicy policy = KdfPolicy.standard,
  }) async {
    final inner = decode(save).manifest;
    final kdf = policy.newParams();
    final key = await CryptoBox.deriveKeyAsync(password, kdf);
    final nonce = CryptoBox.randomBytes(CryptoBox.nonceLength);
    final sealed = CryptoBox.seal(
      key: key,
      nonce: nonce,
      plaintext: save,
      aad: _payloadAad,
    );
    key.fillRange(0, key.length, 0);
    final outer = SaveManifest(
      formatVersion: inner.formatVersion,
      appVersion: inner.appVersion,
      schemaVersion: inner.schemaVersion,
      deviceId: inner.deviceId,
      deviceName: inner.deviceName,
      createdAt: inner.createdAt,
      maxHlc: null,
      counts: const {},
      files: {payloadPath: sha256Hex(sealed)},
      encryption: SaveManifest.encryptionAesGcm,
      encryptionParams: {
        'kdf': kdf.toJson(),
        'nonce': base64.encode(nonce),
        'payload': payloadPath,
      },
    );
    final manifestBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(outer.toJson()),
    );
    final archive = Archive()
      ..addFile(ArchiveFile.bytes(manifestPath, manifestBytes))
      ..addFile(
        ArchiveFile.string(manifestChecksumPath, sha256Hex(manifestBytes)),
      )
      ..addFile(ArchiveFile.bytes(payloadPath, sealed));
    return ZipEncoder().encodeBytes(archive);
  }

  /// Abre um save protegido por senha e devolve o save original (a validar
  /// com [decode]). Lança [DataError] se a senha estiver errada ou o arquivo
  /// tiver sido alterado (o AES-GCM não distingue os dois).
  static Future<Uint8List> unprotect(List<int> bytes, String password) async {
    final entries = _entries(bytes);
    final outer = _manifest(entries);
    if (outer.encryption == SaveManifest.encryptionNone) {
      return Uint8List.fromList(bytes);
    }
    if (outer.encryption != SaveManifest.encryptionAesGcm) {
      throw DataError(
        'Este save usa uma proteção que esta versão do Patrion não conhece '
        '(${outer.encryption}). Atualize o aplicativo.',
      );
    }
    final payload = entries[payloadPath];
    final expected = outer.files[payloadPath];
    if (payload == null || expected == null) _corrupt('conteúdo ausente');
    if (sha256Hex(payload) != expected) _corrupt('checksum do conteúdo');
    for (final name in entries.keys) {
      if (name != manifestPath &&
          name != manifestChecksumPath &&
          name != payloadPath) {
        _corrupt('arquivo não declarado');
      }
    }
    final params = outer.encryptionParams;
    final nonceText = params['nonce'];
    if (nonceText is! String) _corrupt('parâmetros da proteção');
    final kdf = KdfParams.fromJson(params['kdf']);
    final key = await CryptoBox.deriveKeyAsync(password, kdf);
    final Uint8List save;
    try {
      save = CryptoBox.open(
        key: key,
        nonce: CryptoBox.decodeBase64(nonceText),
        sealed: payload,
        aad: _payloadAad,
      );
    } on WrongSecretError {
      throw const DataError(
        'Senha do arquivo incorreta, ou o arquivo foi alterado. Nada foi '
        'importado.',
      );
    } finally {
      key.fillRange(0, key.length, 0);
    }
    // O manifesto de dentro (autenticado) precisa bater com o de fora.
    final inner = decode(save).manifest;
    if (inner.deviceId != outer.deviceId ||
        inner.createdAt != outer.createdAt) {
      _corrupt('manifesto externo diferente do interno');
    }
    return save;
  }

  static Map<String, Uint8List> _entries(List<int> bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      return {
        for (final f in archive.files)
          if (f.isFile) f.name: f.readBytes() ?? Uint8List(0),
      };
    } catch (_) {
      throw const DataError(
        'O arquivo não é um save do Patrion ou está corrompido (ZIP '
        'ilegível). Nada foi importado.',
      );
    }
  }

  static SaveManifest _manifest(Map<String, Uint8List> entries) {
    final manifestBytes = entries[manifestPath];
    final manifestSum = entries[manifestChecksumPath];
    if (manifestBytes == null || manifestSum == null) {
      throw const DataError(
        'O arquivo não é um save do Patrion (sem manifesto). Nada foi '
        'importado.',
      );
    }
    if (_ascii(manifestSum).trim() != sha256Hex(manifestBytes)) {
      _corrupt('checksum do manifesto');
    }
    try {
      return SaveManifest.fromJson(jsonDecode(utf8.decode(manifestBytes)));
    } on FormatException {
      _corrupt('manifesto ilegível');
    }
  }

  static Never _corrupt(String detail) => throw DataError(
    'O arquivo de save está corrompido ou foi alterado ($detail). Nada foi '
    'importado.',
  );

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
