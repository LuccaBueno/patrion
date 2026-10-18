import '../../core/crypto/database_key.dart';

/// Confirmação do usuário pelo Windows Hello (rosto, digital ou PIN), atrás
/// de uma interface para os testes e para a biometria do celular no futuro.
abstract interface class HelloAuthenticator {
  /// O Windows Hello está configurado neste PC.
  Future<bool> isAvailable();

  /// Pede a confirmação. `false` se o usuário cancelar ou falhar.
  Future<bool> verify(String reason);
}

/// Cópia da chave do banco que só é liberada depois do Windows Hello,
/// protegida pelo Windows para o usuário logado (DECISIONS D-32).
abstract interface class HelloKeyVault {
  bool get exists;

  void store(DatabaseKey key, String keyId);

  /// A chave guardada, se ela for da chave [keyId] e puder ser aberta.
  DatabaseKey? load(String keyId);

  void delete();
}
