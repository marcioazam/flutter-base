import 'package:equatable/equatable.dart';

/// Base class para todas as falhas da aplicação.
/// Usa sealed class para pattern matching exaustivo.
sealed class AppFailure extends Equatable implements Exception {
  const AppFailure(this.message, {this.code, this.stackTrace, this.context});
  final String message;
  final String? code;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

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
  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
    super.code,
    super.stackTrace,
    super.context,
  });
  final Map<String, List<String>> fieldErrors;

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
///
/// Use cases:
/// - Token refresh failed
/// - Invalid credentials
/// - OAuth flow failed
///
/// See also: [UnauthorizedFailure] for 401 HTTP responses,
/// [SessionExpiredFailure] for explicit session timeout.
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
  const ServerFailure(
    super.message, {
    this.statusCode,
    super.code,
    super.stackTrace,
    super.context,
  });
  final int? statusCode;

  @override
  List<Object?> get props => [message, code, statusCode];

  @override
  String get userMessage => 'Erro no servidor. Tente novamente mais tarde.';
}

/// Falha de recurso não encontrado (404).
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure(
    super.message, {
    this.resourceType,
    this.resourceId,
    super.code,
    super.stackTrace,
    super.context,
  });
  final String? resourceType;
  final String? resourceId;

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
  const RateLimitFailure(
    super.message, {
    this.retryAfter,
    super.code,
    super.stackTrace,
    super.context,
  });
  final Duration? retryAfter;

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

/// Falha de não autorizado (401 HTTP response).
///
/// Use cases:
/// - API returns 401 status code
/// - Missing or invalid Authorization header
///
/// See also: [AuthFailure] for authentication flow failures,
/// [SessionExpiredFailure] for explicit session timeout.
final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage => 'Não autorizado. Faça login novamente.';
}

/// Falha de sessão expirada (explicit timeout).
///
/// Use cases:
/// - JWT token expired (detected client-side)
/// - Session timeout from server
/// - Refresh token expired
///
/// See also: [AuthFailure] for authentication flow failures,
/// [UnauthorizedFailure] for 401 HTTP responses.
final class SessionExpiredFailure extends AppFailure {
  const SessionExpiredFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage => 'Sessão expirada. Faça login novamente.';
}

/// Falha de timeout.
final class TimeoutFailure extends AppFailure {
  const TimeoutFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage => 'Tempo limite excedido. Tente novamente.';
}

/// Falha de cache expirado.
final class CacheExpiredFailure extends AppFailure {
  const CacheExpiredFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage => 'Dados em cache expiraram.';
}

/// Failure when circuit breaker is open.
///
/// **Feature: flutter-2025-final-enhancements**
/// **Validates: Requirements 5.3**
final class CircuitOpenFailure extends AppFailure {
  const CircuitOpenFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.context,
  });

  @override
  String get userMessage =>
      'Serviço temporariamente indisponível. Tente novamente em alguns segundos.';
}
