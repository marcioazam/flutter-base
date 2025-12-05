import 'package:flutter/material.dart';
import 'package:flutter_base_2025/shared/providers/connectivity_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget that shows connectivity status indicator.
class ConnectivityIndicator extends ConsumerWidget {

  const ConnectivityIndicator({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOnline ? 0 : 32,
          color: Colors.red.shade700,
          child: isOnline
              ? const SizedBox.shrink()
              : const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'No internet connection',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Snackbar-based connectivity indicator.
class ConnectivitySnackbar extends ConsumerStatefulWidget {

  const ConnectivitySnackbar({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<ConnectivitySnackbar> createState() =>
      _ConnectivitySnackbarState();
}

class _ConnectivitySnackbarState extends ConsumerState<ConnectivitySnackbar> {
  bool? _previousOnline;

  @override
  Widget build(BuildContext context) {
    ref.listen(isOnlineProvider, (previous, next) {
      if (_previousOnline != null && _previousOnline != next) {
        _showConnectivitySnackbar(context, next);
      }
      _previousOnline = next;
    });

    return widget.child;
  }

  void _showConnectivitySnackbar(BuildContext context, bool isOnline) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(isOnline ? 'Back online' : 'No internet connection'),
          ],
        ),
        backgroundColor: isOnline ? Colors.green : Colors.red,
        duration: Duration(seconds: isOnline ? 2 : 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
