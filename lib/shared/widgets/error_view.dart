import 'package:flutter/material.dart';

import 'package:flutter_base_2025/core/errors/failures.dart';

/// Generic error view with retry action.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.error,
    required this.onRetry,
    this.title,
    super.key,
  });

  final Object error;
  final VoidCallback onRetry;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final failure = error is AppFailure ? error as AppFailure : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getIcon(failure), size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              title ?? _getTitle(failure),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getMessage(failure),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(AppFailure? failure) => switch (failure) {
    NetworkFailure() => Icons.wifi_off,
    AuthFailure() => Icons.lock_outline,
    NotFoundFailure() => Icons.search_off,
    ServerFailure() => Icons.cloud_off,
    ValidationFailure() => Icons.error_outline,
    _ => Icons.error_outline,
  };

  String _getTitle(AppFailure? failure) => switch (failure) {
    NetworkFailure() => 'Sem conexão',
    AuthFailure() => 'Sessão expirada',
    NotFoundFailure() => 'Não encontrado',
    ServerFailure() => 'Erro no servidor',
    ValidationFailure() => 'Dados inválidos',
    _ => 'Algo deu errado',
  };

  String _getMessage(AppFailure? failure) =>
      failure?.userMessage ?? 'Ocorreu um erro inesperado.';
}

/// Async value error widget builder.
class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({
    required this.error,
    required this.stackTrace,
    required this.onRetry,
    super.key,
  });

  final Object error;
  final StackTrace stackTrace;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) =>
      ErrorView(error: error, onRetry: onRetry);
}

/// Loading view with optional message.
class LoadingView extends StatelessWidget {
  const LoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state view.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.actionLabel,
    super.key,
  });

  final String message;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(onPressed: action, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom error widget builder for Flutter errors.
Widget buildErrorWidget(FlutterErrorDetails details) => Material(
  child: Container(
    color: Colors.red.shade50,
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: .center,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Ocorreu um erro',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          details.exceptionAsString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ],
    ),
  ),
);
