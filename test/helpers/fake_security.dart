import 'dart:typed_data';

import 'package:patrion/application/security/security_ports.dart';
import 'package:patrion/core/crypto/database_key.dart';

/// Windows Hello de mentira: disponível e confirmando, a menos que o teste
/// mude.
class FakeHello implements HelloAuthenticator {
  bool available = true;
  bool confirms = true;
  int prompts = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> verify(String reason) async {
    prompts++;
    return confirms;
  }
}

/// Cofre do Windows Hello em memória (o real usa o DPAPI).
class MemoryHelloVault implements HelloKeyVault {
  (String, List<int>)? _stored;

  @override
  bool get exists => _stored != null;

  @override
  void store(DatabaseKey key, String keyId) =>
      _stored = (keyId, List.of(key.bytes));

  @override
  DatabaseKey? load(String keyId) {
    final s = _stored;
    if (s == null || s.$1 != keyId) return null;
    return DatabaseKey(Uint8List.fromList(s.$2));
  }

  @override
  void delete() => _stored = null;
}
