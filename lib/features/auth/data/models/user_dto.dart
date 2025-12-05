import 'package:flutter_base_2025/features/auth/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// UserDto - Data Transfer Object for User entity.
/// Uses freezed for immutability and json_serializable for serialization.
@freezed
abstract class UserDto with _$UserDto {
  const UserDto._();

  const factory UserDto({
    required String id,
    required String email,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserDto;

  /// Creates DTO from domain entity.
  factory UserDto.fromEntity(User user) => UserDto(
        id: user.id,
        email: user.email,
        name: user.name,
        avatarUrl: user.avatarUrl,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      );

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  /// Converts DTO to domain entity.
  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
