import 'package:equatable/equatable.dart';

/// Base class para todas as falhas da aplicação.
/// Usa sealed class para pattern matching exaustivo.
sealed class AppFailure extends Equatable {
  final String message;
  final String? code;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

  const AppFailure(
    this.message, {
    this.code,
    this.stackTrace,
    this.context,
  });

  @override
  List<Object?> get props => [message, code];

  /// Retorna mensagem amigável para o usuário.
  String get userMessage => message;
}

/// Falha de rede (sem conexão, timeout, etc).
final class NetworkFailure extends AppFailure {
  const NetworkFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage => 'Erro de conexão. Verifique sua internet.';
}

/// Falha de cache/armazenamento local.
final class CacheFailure extends AppFailure {
  const CacheFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage => 'Erro ao acessar dados locais.';
}

/// Falha de validação com erros por campo.
final class ValidationFailure extends AppFailure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];

  /// Retorna erros de um campo específico.
  List<String> errorsFor(String field) => fieldErrors[field] ?? [];

  /// Retorna true se há erro em um campo específico.
  bool hasErrorFor(String field) => fieldErrors.containsKey(field);

  /// Retorna o primeiro erro de um campo, ou null.
  String? firstErrorFor(String field) => errorsFor(field).firstOrNull;

  @override
  String get userMessage => 'Por favor, corrija os erros no formulário.';
}

/// Falha de autenticação (token inválido, expirado, etc).
final class AuthFailure extends AppFailure {
  const AuthFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage => 'Sessão expirada. Faça login novamente.';
}

/// Falha do servidor (5xx, erro interno, etc).
final class ServerFailure extends AppFailure {
  final int? statusCode;

  const ServerFailure(
    super.message, {
    this.statusCode,
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  List<Object?> get props => [message, code, statusCode];

  @override
  String get userMessage => 'Erro no servidor. Tente novamente mais tarde.';
}

/// Falha de recurso não encontrado (404).
final class NotFoundFailure extends AppFailure {
  final String? resourceType;
  final String? resourceId;

  const NotFoundFailure(
    super.message, {
    this.resourceType,
    this.resourceId,
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  List<Object?> get props => [message, code, resourceType, resourceId];

  @override
  String get userMessage => 'Recurso não encontrado.';
}

/// Falha de permissão (403).
final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage => 'Você não tem permissão para esta ação.';
}

/// Falha de conflito (409).
final class ConflictFailure extends AppFailure {
  const ConflictFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage => 'Conflito detectado. Atualize e tente novamente.';
}

/// Falha de rate limit (429).
final class RateLimitFailure extends AppFailure {
  final Duration? retryAfter;

  const RateLimitFailure(
    super.message, {
    this.retryAfter,
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  List<Object?> get props => [message, code, retryAfter];

  @override
  String get userMessage => 'Muitas requisições. Aguarde um momento.';
}

/// Falha inesperada/desconhecida.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage => 'Erro inesperado. Tente novamente.';
}
