// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, unused_element, unnecessary_cast, invalid_annotation_target

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  avatarUrl: json['avatar_url'] as String?,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'created_at': instance.createdAt.toIso8601String(),
  'avatar_url': ?instance.avatarUrl,
  'updated_at': ?instance.updatedAt?.toIso8601String(),
};
