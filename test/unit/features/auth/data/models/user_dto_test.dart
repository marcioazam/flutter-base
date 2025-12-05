import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart';

import 'package:flutter_base_2025/features/auth/data/models/user_dto.dart';
import 'package:flutter_base_2025/features/auth/domain/entities/user.dart';

/// Custom generator for UserDto
extension UserDtoArbitrary on Any {
  Arbitrary<UserDto> get userDto => combine5(
        any.nonEmptyLetters,
        any.nonEmptyLetters.map((s) => '$s@test.com'),
        any.nonEmptyLetters,
        any.dateTime,
        any.bool,
        (id, email, name, createdAt, hasAvatar) => UserDto(
          id: id,
          email: email,
          name: name,
          avatarUrl: hasAvatar ? 'https://example.com/avatar.png' : null,
          createdAt: createdAt,
          updatedAt: null,
        ),
      );

  Arbitrary<UserDto> get userDtoWithNullables => combine6(
        any.nonEmptyLetters,
        any.nonEmptyLetters.map((s) => '$s@test.com'),
        any.nonEmptyLetters,
        any.nullableLetters,
        any.dateTime,
        any.nullableDateTime,
        (id, email, name, avatarUrl, createdAt, updatedAt) => UserDto(
          id: id,
          email: email,
          name: name,
          avatarUrl: avatarUrl,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      );
}

extension NullableArbitrary on Any {
  Arbitrary<String?> get nullableLetters =>
      any.bool.flatMap((isNull) => isNull ? any.always(null) : any.letters);

  Arbitrary<DateTime?> get nullableDateTime =>
      any.bool.flatMap((isNull) => isNull ? any.always(null) : any.dateTime);
}

void main() {
  group('UserDto Serialization', () {
    group('Basic Tests', () {
      test('fromJson creates valid UserDto', () {
        final json = {
          'id': '123',
          'email': 'test@example.com',
          'name': 'Test User',
          'avatar_url': 'https://example.com/avatar.png',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
        };

        final dto = UserDto.fromJson(json);

        expect(dto.id, equals('123'));
        expect(dto.email, equals('test@example.com'));
        expect(dto.name, equals('Test User'));
        expect(dto.avatarUrl, equals('https://example.com/avatar.png'));
        expect(dto.createdAt, equals(DateTime.utc(2024, 1, 1)));
        expect(dto.updatedAt, equals(DateTime.utc(2024, 1, 2)));
      });

      test('toJson produces valid JSON', () {
        final dto = UserDto(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          avatarUrl: 'https://example.com/avatar.png',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
        );

        final json = dto.toJson();

        expect(json['id'], equals('123'));
        expect(json['email'], equals('test@example.com'));
        expect(json['name'], equals('Test User'));
        expect(json['avatar_url'], equals('https://example.com/avatar.png'));
        expect(json['created_at'], equals('2024-01-01T00:00:00.000Z'));
        expect(json['updated_at'], equals('2024-01-02T00:00:00.000Z'));
      });

      test('toEntity creates valid User entity', () {
        final dto = UserDto(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.utc(2024, 1, 1),
        );

        final entity = dto.toEntity();

        expect(entity.id, equals(dto.id));
        expect(entity.email, equals(dto.email));
        expect(entity.name, equals(dto.name));
        expect(entity.createdAt, equals(dto.createdAt));
      });

      test('fromEntity creates valid UserDto', () {
        final entity = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.utc(2024, 1, 1),
        );

        final dto = UserDto.fromEntity(entity);

        expect(dto.id, equals(entity.id));
        expect(dto.email, equals(entity.email));
        expect(dto.name, equals(entity.name));
        expect(dto.createdAt, equals(entity.createdAt));
      });
    });

    group('Property Tests', () {
      /// **Feature: flutter-base-2025, Property 1: Serialization Round-Trip Consistency**
      /// **Validates: Requirements 5.1, 5.2, 5.3**
      Glados(any.userDto, iterations: 100).test(
        'round-trip serialization preserves equality',
        (dto) {
          final json = dto.toJson();
          final restored = UserDto.fromJson(json);

          expect(restored, equals(dto));
        },
      );

      /// **Feature: flutter-base-2025, Property 1: Serialization Round-Trip Consistency**
      Glados(any.userDto, iterations: 100).test(
        'toJson produces valid JSON that can be parsed',
        (dto) {
          final json = dto.toJson();

          expect(json, isA<Map<String, dynamic>>());
          expect(json['id'], isA<String>());
          expect(json['email'], isA<String>());
          expect(json['name'], isA<String>());
          expect(json['created_at'], isA<String>());
        },
      );

      /// **Feature: flutter-base-2025, Property 2: Nullable Field Handling**
      /// **Validates: Requirements 5.4**
      Glados(any.userDtoWithNullables, iterations: 100).test(
        'nullable fields are handled correctly in round-trip',
        (dto) {
          final json = dto.toJson();
          final restored = UserDto.fromJson(json);

          expect(restored.avatarUrl, equals(dto.avatarUrl));
          expect(restored.updatedAt, equals(dto.updatedAt));
        },
      );

      /// **Feature: flutter-base-2025, Property 2: Nullable Field Handling**
      Glados(any.userDtoWithNullables, iterations: 100).test(
        'null fields are excluded from JSON output',
        (dto) {
          final json = dto.toJson();

          if (dto.avatarUrl == null) {
            expect(json.containsKey('avatar_url'), isFalse);
          }
          if (dto.updatedAt == null) {
            expect(json.containsKey('updated_at'), isFalse);
          }
        },
      );

      /// **Feature: flutter-base-2025, Property 3: Unknown Field Tolerance**
      /// **Validates: Requirements 5.5**
      Glados(any.userDto, iterations: 100).test(
        'unknown fields in JSON are ignored',
        (dto) {
          final json = dto.toJson();
          // Add unknown fields
          json['unknown_field'] = 'should be ignored';
          json['another_unknown'] = 12345;
          json['nested_unknown'] = {'key': 'value'};

          final restored = UserDto.fromJson(json);

          expect(restored, equals(dto));
        },
      );

      /// Entity mapping round-trip
      Glados(any.userDto, iterations: 100).test(
        'entity mapping round-trip preserves data',
        (dto) {
          final entity = dto.toEntity();
          final restoredDto = UserDto.fromEntity(entity);

          expect(restoredDto, equals(dto));
        },
      );
    });
  });
}
