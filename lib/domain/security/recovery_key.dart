import 'dart:typed_data';

/// Chave de recuperação do bloqueio (SPEC §3, DECISIONS D-32): 160 bits em
/// Base32 de Crockford, 32 caracteres mostrados em 8 grupos de 4
/// (`XXXX-XXXX-…`).
abstract final class RecoveryKey {
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  static const byteLength = 20;
  static const length = 32;

  /// Texto para mostrar ao usuário, a partir de 20 bytes aleatórios.
  static String format(Uint8List bytes) {
    if (bytes.length != byteLength) {
      throw ArgumentError('A chave de recuperação tem 20 bytes');
    }
    final chars = StringBuffer();
    var buffer = 0;
    var bits = 0;
    for (final b in bytes) {
      buffer = (buffer << 8) | b;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        chars.write(_alphabet[(buffer >> bits) & 31]);
      }
      buffer &= (1 << bits) - 1;
    }
    final text = chars.toString();
    return [for (var i = 0; i < text.length; i += 4) text.substring(i, i + 4)]
        .join('-');
  }

  /// Forma canônica (32 caracteres, sem separadores) do que o usuário
  /// digitou, ou `null` se não for uma chave válida. Ignora hífens, espaços
  /// e maiúsculas/minúsculas; lê O como 0 e I/L como 1.
  static String? normalize(String input) {
    final out = StringBuffer();
    for (final rune in input.toUpperCase().runes) {
      var c = String.fromCharCode(rune);
      if (c == '-' || c.trim().isEmpty) continue;
      c = switch (c) {
        'O' => '0',
        'I' || 'L' => '1',
        _ => c,
      };
      if (!_alphabet.contains(c)) return null;
      out.write(c);
    }
    final text = out.toString();
    return text.length == length ? text : null;
  }
}

/// Regras da senha do bloqueio.
abstract final class PasswordPolicy {
  static const minLength = 8;

  /// Mensagem do problema, ou `null` se a senha serve.
  static String? check(String password) {
    if (password.runes.length < minLength) {
      return 'Use pelo menos $minLength caracteres.';
    }
    if (password.trim().isEmpty) return 'A senha não pode ser só espaços.';
    return null;
  }
}
