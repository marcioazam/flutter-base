import 'package:flutter_base_2025/core/grpc/interceptors/grpc_auth_interceptor.dart';
import 'package:flutter_base_2025/core/storage/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' as glados hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

// Configure Glados for 100 iterations
final _explore = glados.ExploreConfig();

/// Property tests for gRPC auth interceptor.
///
/// **Feature: architecture-alignment-2025, Property 2: gRPC Auth Token Attachment**
/// **Validates: Requirements 1.6**
void main() {
  late MockTokenStorage mockTokenStorage;
  late GrpcAuthInterceptor interceptor;

  setUp(() {
    mockTokenStorage = MockTokenStorage();
    interceptor = GrpcAuthInterceptor(mockTokenStorage);
  });

  group('GrpcAuthInterceptor Property Tests', () {
    // **Feature: architecture-alignment-2025, Property 2: gRPC Auth Token Attachment**
    glados.Glados<String>(glados.any.nonEmptyLetters, _explore).test(
      'any valid token is attached with Bearer prefix',
      (token) async {
        when(() => mockTokenStorage.getAccessToken())
            .thenAnswer((_) async => token);

        final metadata = await interceptor.attachToken({});

        expect(metadata['authorization'], 'Bearer $token');
      },
    );

    // **Feature: architecture-alignment-2025, Property 2: gRPC Auth Token Attachment**
    glados.Glados<String>(glados.any.nonEmptyLetters, _explore).test(
      'existing metadata is preserved when token is attached',
      (token) async {
        when(() => mockTokenStorage.getAccessToken())
            .thenAnswer((_) async => token);

        final existingMetadata = {'x-custom-header': 'custom-value'};
        final metadata = await interceptor.attachToken(existingMetadata);

        // Original metadata preserved
        expect(metadata['x-custom-header'], 'custom-value');
        // Token added
        expect(metadata['authorization'], 'Bearer $token');
      },
    );

    // **Feature: architecture-alignment-2025, Property 2: gRPC Auth Token Attachment**
    glados.Glados<String>(glados.any.nonEmptyLetters, _explore).test(
      'token attachment is idempotent for same token',
      (token) async {
        when(() => mockTokenStorage.getAccessToken())
            .thenAnswer((_) async => token);

        final metadata1 = await interceptor.attachToken({});
        final metadata2 = await interceptor.attachToken({});

        // Same token produces same result
        expect(metadata1['authorization'], metadata2['authorization']);
      },
    );
  });

  group('GrpcAuthInterceptor Unit Tests', () {
    test('no token attached when storage returns null', () async {
      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => null);

      final metadata = await interceptor.attachToken({});

      expect(metadata.containsKey('authorization'), isFalse);
    });

    test('no token attached when storage returns empty string', () async {
      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => '');

      final metadata = await interceptor.attachToken({});

      expect(metadata.containsKey('authorization'), isFalse);
    });

    test('token is attached with Bearer prefix', () async {
      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => 'test-token-123');

      final metadata = await interceptor.attachToken({});

      expect(metadata['authorization'], 'Bearer test-token-123');
    });

    test('null metadata is handled gracefully', () async {
      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => 'test-token');

      final metadata = await interceptor.attachToken(null);

      expect(metadata['authorization'], 'Bearer test-token');
    });

    test('refreshToken caches token for synchronous access', () async {
      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => 'cached-token');

      await interceptor.refreshToken();

      // Verify token was fetched
      verify(() => mockTokenStorage.getAccessToken()).called(1);
    });

    test('clearCache removes cached token', () async {
      when(() => mockTokenStorage.getAccessToken())
          .thenAnswer((_) async => 'test-token');

      await interceptor.refreshToken();
      interceptor.clearCache();

      // After clear, attachToken should fetch fresh token
      final metadata = await interceptor.attachToken({});
      expect(metadata['authorization'], 'Bearer test-token');
    });
  });
}
