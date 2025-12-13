import 'package:flutter_base_2025/features/auth/data/dtos/user_dto.dart';
import 'package:flutter_base_2025/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;

import '../helpers/generators.dart';

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-modernization-2025, Property 3: DTO Round-Trip Consistency**
/// **Feature: flutter-modernization-2025, Property 4: Entity-DTO Mapping Consistency**
/// **Validates: Requirements 6.3, 6.4**
void main() {
  group('DTO Round-Trip Properties', () {
    Glados(any.userDto, _explore).test(
      'UserDto JSON round-trip preserves equality',
      (dto) {
        final json = dto.toJson();
        final restored = UserDto.fromJson(json);

        expect(restored.id, equals(dto.id));
        expect(restored.email, equals(dto.email));
        expect(restored.name, equals(dto.name));
        expect(
          restored.createdAt.millisecondsSinceEpoch,
          equals(dto.createdAt.millisecondsSinceEpoch),
        );
      },
    );
  });

  group('Entity-DTO Mapping Properties', () {
    Glados(any.user, _explore).test('User to UserDto to User preserves data', (
      user,
    ) {
      final dto = UserDto.fromEntity(user);
      final restored = dto.toEntity();

      expect(restored.id, equals(user.id));
      expect(restored.email, equals(user.email));
      expect(restored.name, equals(user.name));
      expect(
        restored.createdAt.millisecondsSinceEpoch,
        equals(user.createdAt.millisecondsSinceEpoch),
      );
    });

    Glados(any.userDto, _explore).test(
      'UserDto to User to UserDto preserves data',
      (dto) {
        final entity = dto.toEntity();
        final restored = UserDto.fromEntity(entity);

        expect(restored.id, equals(dto.id));
        expect(restored.email, equals(dto.email));
        expect(restored.name, equals(dto.name));
      },
    );
  });

  group('DTO Validation', () {
    test('UserDto.toEntity creates valid User', () {
      final dto = UserDto(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
      );

      final user = dto.toEntity();

      expect(user, isA<User>());
      expect(user.id, equals(dto.id));
      expect(user.email, equals(dto.email));
    });

    test('UserDto.fromEntity creates valid DTO', () {
      final user = User(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
      );

      final dto = UserDto.fromEntity(user);

      expect(dto, isA<UserDto>());
      expect(dto.id, equals(user.id));
      expect(dto.email, equals(user.email));
    });
  });
}
