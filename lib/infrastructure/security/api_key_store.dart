import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../application/market/market_ports.dart';
import '../../core/errors/app_error.dart';
import 'dpapi.dart';

final _log = Logger('chaves');

/// Chaves de API num arquivo ao lado do banco (`patrion.apikeys.bin`),
/// protegido pelo DPAPI do usuário do Windows (DECISIONS D-34).
///
/// - Fica fora do banco: não vai no save nem nos backups.
/// - Só abre na mesma conta do Windows, no mesmo PC: uma cópia da pasta de
///   dados em outro lugar não revela as chaves.
/// - Nada aqui vai para o log, nem o nome do provedor junto da chave.
class DpapiApiKeyStore implements ApiKeyStore {
  DpapiApiKeyStore(this.dataDir);

  static const fileName = 'patrion.apikeys.bin';
  static final _entropy = Uint8List.fromList(utf8.encode('patrion-apikeys-v1'));

  final String dataDir;
  Map<String, String>? _cache;

  String get path => p.join(dataDir, fileName);

  Map<String, String> _load() {
    final cached = _cache;
    if (cached != null) return cached;
    final file = File(path);
    if (!file.existsSync()) return _cache = {};
    try {
      final plain = Dpapi.unprotect(file.readAsBytesSync(), _entropy);
      final map = (jsonDecode(utf8.decode(plain)) as Map<String, Object?>).map(
        (k, v) => MapEntry(k, '$v'),
      );
      plain.fillRange(0, plain.length, 0);
      return _cache = map;
    } on Object catch (error) {
      _log.warning('Arquivo de chaves de API ilegível', error.runtimeType);
      throw const DataError(
        'As chaves de API deste computador não puderam ser lidas (arquivo de '
        'outra conta do Windows ou alterado). Cadastre as chaves de novo em '
        'Fontes de dados.',
      );
    }
  }

  void _save(Map<String, String> map) {
    if (map.isEmpty) {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
      _cache = {};
      return;
    }
    final plain = Uint8List.fromList(utf8.encode(jsonEncode(map)));
    final sealed = Dpapi.protect(plain, _entropy);
    plain.fillRange(0, plain.length, 0);
    final temp = File('$path.novo')..writeAsBytesSync(sealed, flush: true);
    temp.renameSync(path);
    _cache = Map.of(map);
  }

  @override
  String? read(String provider) {
    try {
      return _load()[provider];
    } on DataError {
      return null;
    }
  }

  @override
  void write(String provider, String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      delete(provider);
      return;
    }
    Map<String, String> current;
    try {
      current = Map.of(_load());
    } on DataError {
      current = {};
    }
    _save(current..[provider] = trimmed);
    _log.info('Chave de API gravada');
  }

  @override
  void delete(String provider) {
    Map<String, String> current;
    try {
      current = Map.of(_load());
    } on DataError {
      current = {};
    }
    if (current.remove(provider) != null) _log.info('Chave de API removida');
    _save(current);
  }

  @override
  Set<String> providersWithKey() {
    try {
      return _load().keys.toSet();
    } on DataError {
      return const {};
    }
  }
}

/// Chaves em memória (testes e plataformas sem DPAPI).
class MemoryApiKeyStore implements ApiKeyStore {
  final _keys = <String, String>{};

  @override
  String? read(String provider) => _keys[provider];

  @override
  void write(String provider, String key) {
    if (key.trim().isEmpty) {
      _keys.remove(provider);
    } else {
      _keys[provider] = key.trim();
    }
  }

  @override
  void delete(String provider) => _keys.remove(provider);

  @override
  Set<String> providersWithKey() => _keys.keys.toSet();
}
