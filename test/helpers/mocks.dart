import 'package:flutter_base_2025/core/network/api_client.dart';
import 'package:flutter_base_2025/core/storage/token_storage.dart';
import 'package:flutter_base_2025/features/auth/data/data_sources/auth_remote_datasource.dart';
import 'package:flutter_base_2025/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_base_2025/shared/providers/connectivity_provider.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockApiClient extends Mock implements ApiClient {}

class MockConnectivityService extends Mock implements ConnectivityService {}

// Fake classes for registerFallbackValue
class FakeUri extends Fake implements Uri {}

class FakeStackTrace extends Fake implements StackTrace {}

/// Setup all fallback values for mocktail.
void setupMocktailFallbacks() {
  registerFallbackValue(FakeUri());
  registerFallbackValue(FakeStackTrace());
}
