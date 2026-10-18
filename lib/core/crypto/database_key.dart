import 'dart:typed_data';

import 'crypto_box.dart';

/// Chave do banco criptografado (256 bits aleatórios, DECISIONS D-32),
/// passada ao SQLCipher como chave bruta.
///
/// Fica na memória só enquanto o banco está aberto; [destroy] zera os bytes
/// ao bloquear. O texto do `PRAGMA key` é uma `String` do Dart, que não pode
/// ser zerada: ela some quando o coletor de lixo a recolhe.
class DatabaseKey {
  DatabaseKey(Uint8List bytes) : _bytes = Uint8List.fromList(bytes) {
    if (bytes.length != CryptoBox.keyLength) {
      throw ArgumentError('A chave do banco deve ter 32 bytes');
    }
  }

  factory DatabaseKey.random() =>
      DatabaseKey(CryptoBox.randomBytes(CryptoBox.keyLength));

  final Uint8List _bytes;
  bool _destroyed = false;

  Uint8List get bytes {
    if (_destroyed) throw StateError('Chave do banco já descartada');
    return _bytes;
  }

  /// Valor para `PRAGMA key = …` e `ATTACH … KEY …`: `"x'<hex>'"`.
  String get pragmaValue {
    final hex = StringBuffer();
    for (final b in bytes) {
      hex.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return '"x\'$hex\'"';
  }

  bool sameAs(DatabaseKey? other) =>
      other != null && CryptoBox.equalBytes(bytes, other.bytes);

  /// Zera a chave na memória.
  void destroy() {
    _bytes.fillRange(0, _bytes.length, 0);
    _destroyed = true;
  }

  @override
  String toString() => 'DatabaseKey(***)';
}
