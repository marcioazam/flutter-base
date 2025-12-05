import 'package:flutter/material.dart';

import '../../core/observability/crash_reporter.dart';

// Widget Previewer annotations for IDE preview support (Flutter 3.38+)
// @Preview(name: 'Error State', width: 400, height: 300)
// @Preview(name: 'Compact Error', width: 400, height: 100)

/// Error boundary widget that catches and displays errors gracefully.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stack, VoidCallback retry)?
      errorBuilder;
  final void Function(Object error, StackTrace? stack)? onError;
  final CrashReporter? crashReporter;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.crashReporter,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  void _handleError(Object error, StackTrace? stack) {
    setState(() {
      _error = error;
      _stackTrace = stack;
    });

    widget.onError?.call(error, stack);
    widget.crashReporter?.reportError(error, stack);
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace, _retry) ??
          DefaultErrorWidget(error: _error!, onRetry: _retry);
    }

    return _ErrorBoundaryInherited(
      onError: _handleError,
      child: widget.child,
    );
  }
}

class _ErrorBoundaryInherited extends InheritedWidget {
  final void Function(Object, StackTrace?) onError;

  const _ErrorBoundaryInherited({
    required this.onError,
    required super.child,
  });

  static _ErrorBoundaryInherited? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ErrorBoundaryInherited>();
  }

  @override
  bool updateShouldNotify(_ErrorBoundaryInherited oldWidget) => false;
}

/// Extension to report errors to nearest ErrorBoundary.
extension ErrorBoundaryContext on BuildContext {
  void reportError(Object error, [StackTrace? stack]) {
    _ErrorBoundaryInherited.of(this)?.onError(error, stack);
  }
}

/// Default error widget with retry button.
class DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const DefaultErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Algo deu errado',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getErrorMessage(error),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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

  String _getErrorMessage(Object error) {
    final message = error.toString();
    if (message.length > 100) {
      return '${message.substring(0, 100)}...';
    }
    return message;
  }
}

/// Compact error widget for inline use.
class CompactErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CompactErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
        ],
      ),
    );
  }
}
