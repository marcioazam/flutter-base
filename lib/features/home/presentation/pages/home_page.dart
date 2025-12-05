import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

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
            onPressed: () => ref.read(logoutNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: authState.when(
          data: (state) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home, size: 64),
              const SizedBox(height: 16),
              Text(
                'Welcome${state.user != null ? ', ${state.user!.name}' : ''}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Flutter Base 2025',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Error loading user'),
        ),
      ),
    );
  }
}
