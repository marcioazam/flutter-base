import 'package:flutter/material.dart';
import 'package:flutter_base_2025/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(logoutProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: authState.when(
          data: (state) {
            final user = state.user;
            return Column(
              mainAxisAlignment: .center,
              children: [
                const Icon(Icons.home, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Welcome${user != null ? ', ${user.name}' : ''}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Flutter Base 2025',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Error loading user'),
        ),
      ),
    );
  }
}
