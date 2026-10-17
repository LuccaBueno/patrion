/// Erros do app, diferenciados por tipo (SPEC §18).
///
/// A mensagem é para o usuário (em português) e não deve conter valores
/// patrimoniais, porque os erros também vão para o log (regra 7).
sealed class AppError implements Exception {
  const AppError(this.message, {this.cause});

  final String message;
  final Object? cause;

  /// Rótulo do tipo, usado no log e na tela.
  String get kind;

  @override
  String toString() =>
      cause == null ? '$kind: $message' : '$kind: $message ($cause)';
}

/// Falha de rede: sem conexão, tempo esgotado, provedor fora do ar.
final class NetworkError extends AppError {
  const NetworkError(super.message, {super.cause});

  @override
  String get kind => 'rede';
}

/// Dado inválido, ausente ou inconsistente (banco, save, provedor).
final class DataError extends AppError {
  const DataError(super.message, {super.cause});

  @override
  String get kind => 'dados';
}

/// Cálculo impossível ou fora do domínio (divisão por zero, série vazia).
final class CalculationError extends AppError {
  const CalculationError(super.message, {super.cause});

  @override
  String get kind => 'cálculo';
}

/// Erro inesperado do próprio app.
final class InternalError extends AppError {
  const InternalError(super.message, {super.cause});

  @override
  String get kind => 'interno';
}
