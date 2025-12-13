import 'package:flutter_base_2025/core/network/api_client.dart';
import 'package:flutter_base_2025/features/auth/data/dtos/auth_response_dto.dart';
import 'package:flutter_base_2025/features/auth/data/dtos/user_dto.dart';

/// Remote data source for authentication.
abstract interface class AuthRemoteDataSource {
  Future<AuthResponseDto> login(String email, String password);
  Future<AuthResponseDto> loginWithOAuth(String provider, String token);
  Future<AuthResponseDto> register(String email, String password, String name);
  Future<void> logout();
  Future<UserDto> getCurrentUser();
  Future<AuthResponseDto> refreshToken(String refreshToken);
}

/// Implementation of AuthRemoteDataSource.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<AuthResponseDto> login(String email, String password) async =>
      _apiClient.post<AuthResponseDto>(
        '/auth/login',
        data: {'email': email, 'password': password},
        fromJson: AuthResponseDto.fromJson,
      );

  @override
  Future<AuthResponseDto> loginWithOAuth(String provider, String token) async =>
      _apiClient.post<AuthResponseDto>(
        '/auth/oauth/$provider',
        data: {'token': token},
        fromJson: AuthResponseDto.fromJson,
      );

  @override
  Future<AuthResponseDto> register(
    String email,
    String password,
    String name,
  ) async => _apiClient.post<AuthResponseDto>(
    '/auth/register',
    data: {'email': email, 'password': password, 'name': name},
    fromJson: AuthResponseDto.fromJson,
  );

  @override
  Future<void> logout() async {
    await _apiClient.delete('/auth/logout');
  }

  @override
  Future<UserDto> getCurrentUser() async =>
      _apiClient.get<UserDto>('/auth/me', fromJson: UserDto.fromJson);

  @override
  Future<AuthResponseDto> refreshToken(String refreshToken) async =>
      _apiClient.post<AuthResponseDto>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        fromJson: AuthResponseDto.fromJson,
      );
}
