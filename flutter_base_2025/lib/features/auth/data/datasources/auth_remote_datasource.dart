import '../../../../core/network/api_client.dart';
import '../models/user_dto.dart';

/// Remote data source for authentication.
abstract interface class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> loginWithOAuth(String provider, String token);
  Future<AuthResponse> register(String email, String password, String name);
  Future<void> logout();
  Future<UserDto> getCurrentUser();
  Future<AuthResponse> refreshToken(String refreshToken);
}

/// Implementation of AuthRemoteDataSource.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponse> login(String email, String password) async {
    return _apiClient.post<AuthResponse>(
      '/auth/login',
      data: {'email': email, 'password': password},
      fromJson: AuthResponse.fromJson,
    );
  }

  @override
  Future<AuthResponse> loginWithOAuth(String provider, String token) async {
    return _apiClient.post<AuthResponse>(
      '/auth/oauth/$provider',
      data: {'token': token},
      fromJson: AuthResponse.fromJson,
    );
  }

  @override
  Future<AuthResponse> register(
    String email,
    String password,
    String name,
  ) async {
    return _apiClient.post<AuthResponse>(
      '/auth/register',
      data: {'email': email, 'password': password, 'name': name},
      fromJson: AuthResponse.fromJson,
    );
  }

  @override
  Future<void> logout() async {
    await _apiClient.delete('/auth/logout');
  }

  @override
  Future<UserDto> getCurrentUser() async {
    return _apiClient.get<UserDto>(
      '/auth/me',
      fromJson: UserDto.fromJson,
    );
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    return _apiClient.post<AuthResponse>(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
      fromJson: AuthResponse.fromJson,
    );
  }
}

/// Auth response model.
class AuthResponse {
  final UserDto user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}
