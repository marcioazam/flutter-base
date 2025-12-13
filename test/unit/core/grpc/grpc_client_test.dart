import 'package:flutter_base_2025/core/grpc/grpc_client.dart';
import 'package:flutter_base_2025/core/grpc/grpc_config.dart';
import 'package:flutter_base_2025/core/storage/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

/// Unit tests for GrpcClient.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 1.4**
void main() {
  late MockTokenStorage mockTokenStorage;
  late GrpcConfig config;

  setUp(() {
    mockTokenStorage = MockTokenStorage();
    config = const GrpcConfig(host: 'localhost', port: 50051, useTls: false);
  });

  group('GrpcClient', () {
    test('creates channel with correct configuration', () {
      final client = GrpcClient(config: config, tokenStorage: mockTokenStorage);

      expect(client.channel, isNotNull);
      expect(client.isDisposed, isFalse);
    });

    test('reuses same channel on multiple accesses', () {
      final client = GrpcClient(config: config, tokenStorage: mockTokenStorage);

      final channel1 = client.channel;
      final channel2 = client.channel;

      expect(identical(channel1, channel2), isTrue);
    });

    test('createStub returns stub from factory', () {
      final client = GrpcClient(config: config, tokenStorage: mockTokenStorage);

      // Test that createStub calls the factory with the channel
      var factoryCalled = false;
      client.createStub((channel) {
        factoryCalled = true;
        expect(channel, isNotNull);
        return 'stub';
      });

      expect(factoryCalled, isTrue);
    });

    test('dispose closes channel and marks as disposed', () async {
      final client = GrpcClient(config: config, tokenStorage: mockTokenStorage);

      // Access channel to create it
      final _ = client.channel;
      expect(client.isDisposed, isFalse);

      await client.dispose();

      expect(client.isDisposed, isTrue);
    });

    test('throws StateError when accessing channel after dispose', () async {
      final client = GrpcClient(config: config, tokenStorage: mockTokenStorage);

      await client.dispose();

      expect(() => client.channel, throwsStateError);
    });

    test('dispose is idempotent', () async {
      final client = GrpcClient(config: config, tokenStorage: mockTokenStorage);

      await client.dispose();
      await client.dispose(); // Should not throw

      expect(client.isDisposed, isTrue);
    });

    test('interceptors list contains auth and logging interceptors', () {
      final client = GrpcClient(config: config, tokenStorage: mockTokenStorage);

      expect(client.interceptors, hasLength(2));
    });

    test('defaultCallOptions has configured timeout', () {
      final customConfig = const GrpcConfig(
        host: 'localhost',
        port: 50051,
        timeout: Duration(seconds: 60),
      );

      final client = GrpcClient(
        config: customConfig,
        tokenStorage: mockTokenStorage,
      );

      expect(client.defaultCallOptions.timeout, const Duration(seconds: 60));
    });

    test('config getter returns the configuration', () {
      final client = GrpcClient(config: config, tokenStorage: mockTokenStorage);

      expect(client.config, config);
      expect(client.config.host, 'localhost');
      expect(client.config.port, 50051);
    });

    test('callWithRetry succeeds on first attempt', () async {
      final client = GrpcClient(config: config, tokenStorage: mockTokenStorage);

      var callCount = 0;
      final result = await client.callWithRetry(() async {
        callCount++;
        return 'success';
      });

      expect(result, 'success');
      expect(callCount, 1);
    });

    test('callWithRetry respects maxRetries parameter', () async {
      final client = GrpcClient(config: config, tokenStorage: mockTokenStorage);

      var callCount = 0;
      final result = await client.callWithRetry(() async {
        callCount++;
        return 'success';
      }, maxRetries: 5);

      expect(result, 'success');
      expect(callCount, 1);
    });
  });

  group('GrpcConfig', () {
    test('default values are set correctly', () {
      const defaultConfig = GrpcConfig(host: 'api.example.com', port: 443);

      expect(defaultConfig.useTls, isTrue);
      expect(defaultConfig.timeout, const Duration(seconds: 30));
      expect(defaultConfig.maxRetries, 3);
      expect(defaultConfig.retryDelay, const Duration(milliseconds: 500));
    });

    test('fromEnv creates config with environment values', () {
      final envConfig = GrpcConfig.fromEnv(
        host: 'grpc.example.com',
        port: 8443,
        useTls: true,
        timeoutSeconds: 45,
        maxRetries: 5,
        retryDelayMs: 1000,
      );

      expect(envConfig.host, 'grpc.example.com');
      expect(envConfig.port, 8443);
      expect(envConfig.useTls, isTrue);
      expect(envConfig.timeout, const Duration(seconds: 45));
      expect(envConfig.maxRetries, 5);
      expect(envConfig.retryDelay, const Duration(milliseconds: 1000));
    });

    test('toString returns readable representation', () {
      const config = GrpcConfig(host: 'localhost', port: 50051, useTls: false);

      expect(
        config.toString(),
        'GrpcConfig(host: localhost, port: 50051, useTls: false)',
      );
    });
  });
}
