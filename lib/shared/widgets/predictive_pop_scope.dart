import 'package:flutter/material.dart';

// Widget Previewer annotations for IDE preview support (Flutter 3.38+)
// @Preview(name: 'Default', width: 400, height: 300)
// @Preview(name: 'With Unsaved Changes', width: 400, height: 300)

/// Enhanced PopScope for predictive back gesture support (Android 15+).
/// Provides async confirmation dialogs and custom back handling.
class PredictivePopScope extends StatelessWidget {

  const PredictivePopScope({
    required this.child, super.key,
    this.canPop = true,
    this.onPopInvoked,
    this.confirmationDialog,
  });

  /// Creates a PredictivePopScope with unsaved changes confirmation.
  factory PredictivePopScope.unsavedChanges({
    required Widget child, required bool hasUnsavedChanges, Key? key,
    String title = 'Descartar alterações?',
    String message = 'Você tem alterações não salvas. Deseja descartá-las?',
    String confirmText = 'Descartar',
    String cancelText = 'Continuar editando',
  }) => PredictivePopScope(
      key: key,
      canPop: !hasUnsavedChanges,
      confirmationDialog: hasUnsavedChanges
          ? (context) => _showDiscardDialog(
                context,
                title: title,
                message: message,
                confirmText: confirmText,
                cancelText: cancelText,
              )
          : null,
      child: child,
    );
  final Widget child;

  /// Whether the route can be popped.
  final bool canPop;

  /// Callback when pop is invoked. Return true to allow pop, false to block.
  final Future<bool> Function()? onPopInvoked;

  /// Optional confirmation dialog builder.
  final Future<bool> Function(BuildContext context)? confirmationDialog;

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: canPop && onPopInvoked == null && confirmationDialog == null,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        var shouldPop = true;

        // Show confirmation dialog if provided
        if (confirmationDialog != null) {
          shouldPop = await confirmationDialog!(context);
        }
        // Or call custom handler
        else if (onPopInvoked != null) {
          shouldPop = await onPopInvoked!();
        }

        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );

  static Future<bool> _showDiscardDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Mixin for forms that need unsaved changes protection.
mixin UnsavedChangesMixin<T extends StatefulWidget> on State<T> {
  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  void markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void markAsSaved() {
    if (_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = false);
    }
  }

  /// Wrap your form with this to get automatic unsaved changes protection.
  Widget buildWithUnsavedChangesProtection({required Widget child}) => PredictivePopScope.unsavedChanges(
      hasUnsavedChanges: _hasUnsavedChanges,
      child: child,
    );
}
