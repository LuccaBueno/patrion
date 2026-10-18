import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../application/security/security_ports.dart';
import '../../core/crypto/crypto_box.dart';
import '../../core/crypto/database_key.dart';
import 'dpapi.dart';

final _log = Logger('bloqueio');

/// Windows Hello pelo `local_auth` (`UserConsentVerifier` do Windows).
class WindowsHelloAuthenticator implements HelloAuthenticator {
  WindowsHelloAuthenticator({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    if (!Platform.isWindows) return false;
    try {
      return await _auth.isDeviceSupported();
    } on Exception catch (error) {
      _log.warning('Windows Hello indisponível', error);
      return false;
    }
  }

  @override
  Future<bool> verify(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on Exception catch (error) {
      _log.warning('Windows Hello falhou', error);
      return false;
    }
  }
}

/// Chave do banco protegida pelo DPAPI do usuário, em `patrion.hello.bin` ao
/// lado do banco. Abre só na mesma conta do Windows, no mesmo PC.
class DpapiHelloKeyVault implements HelloKeyVault {
  const DpapiHelloKeyVault(this.dataDir);

  static const fileName = 'patrion.hello.bin';
  static final _entropy = Uint8List.fromList(utf8.encode('patrion-hello-v1'));

  final String dataDir;

  String get path => p.join(dataDir, fileName);

  @override
  bool get exists => File(path).existsSync();

  @override
  void store(DatabaseKey key, String keyId) {
    final plain = Uint8List.fromList(
      utf8.encode(
        jsonEncode({'keyId': keyId, 'key': base64.encode(key.bytes)}),
      ),
    );
    final sealed = Dpapi.protect(plain, _entropy);
    plain.fillRange(0, plain.length, 0);
    final temp = File('$path.novo')..writeAsBytesSync(sealed, flush: true);
    temp.renameSync(path);
  }

  @override
  DatabaseKey? load(String keyId) {
    final file = File(path);
    if (!file.existsSync()) return null;
    try {
      final plain = Dpapi.unprotect(file.readAsBytesSync(), _entropy);
      final json = jsonDecode(utf8.decode(plain)) as Map<String, Object?>;
      plain.fillRange(0, plain.length, 0);
      if (json['keyId'] != keyId) return null;
      final bytes = CryptoBox.decodeBase64(json['key']! as String);
      final key = DatabaseKey(bytes);
      bytes.fillRange(0, bytes.length, 0);
      return key;
    } on Object catch (error) {
      _log.warning('Chave do Windows Hello ilegível', error);
      return null;
    }
  }

  @override
  void delete() {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  }
}
