import 'package:flutter_base_2025/features/auth/data/dtos/user_dto.dart';

/// Auth response DTO for authentication endpoints.
class AuthResponseDto {
  AuthResponseDto({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      AuthResponseDto(
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );

  final UserDto user;
  final String accessToken;
  final String refreshToken;

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };
}
