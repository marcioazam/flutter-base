import 'dart:math';

import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/base/paginated_list.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_base_2025/features/auth/data/dtos/user_dto.dart';
import 'package:flutter_base_2025/features/auth/domain/entities/user.dart';
import 'package:glados/glados.dart';

/// Custom generators for property-based testing with Glados.
/// Uses Generator<T> type from Glados library.
extension CustomGenerators on Any {
  /// Generates non-empty strings with letters only (custom version).
  Generator<String> get safeNonEmptyLetters => any.lowercaseLetters.map(
    (s) => s.isEmpty ? 'a' : s.substring(0, min(50, s.length)),
  );

  /// Generates valid email addresses.
  Generator<String> get email => any.lowercaseLetters.map((s) {
    final name = s.isEmpty ? 'user' : s.substring(0, min(20, s.length));
    return '$name@test.com';
  });

  /// Generates valid passwords (6+ characters).
  Generator<String> get password => any.lowercaseLetters.map(
    (s) => s.length < 6 ? 'password123' : s.substring(0, min(50, s.length)),
  );

  /// Generates User entities.
  Generator<User> get user => any.combine4(
    any.lowercaseLetters,
    any.email,
    any.lowercaseLetters,
    any.dateTime,
    (id, email, name, createdAt) => User(
      id: id.isEmpty ? 'id' : id,
      email: email,
      name: name.isEmpty ? 'name' : name,
      createdAt: createdAt,
    ),
  );

  /// Generates UserDto instances.
  Generator<UserDto> get userDto => any.combine4(
    any.lowercaseLetters,
    any.email,
    any.lowercaseLetters,
    any.dateTime,
    (id, email, name, createdAt) => UserDto(
      id: id.isEmpty ? 'id' : id,
      email: email,
      name: name.isEmpty ? 'name' : name,
      createdAt: createdAt,
    ),
  );

  /// Generates nullable strings.
  Generator<String?> get nullableString =>
      any.bool.map((isNull) => isNull ? null : 'test_string');

  /// Generates nullable DateTimes.
  Generator<DateTime?> get nullableDateTime =>
      any.bool.map((isNull) => isNull ? null : DateTime.now());

  /// Generates positive integers (custom to avoid conflict with glados).
  Generator<int> get customPositiveInt => any.int.map((i) => i.abs() + 1);

  /// Generates non-negative integers.
  Generator<int> get nonNegativeInt => any.int.map((i) => i.abs());

  /// Generates percentages (0.0 to 1.0).
  Generator<double> get percentage =>
      any.double.map((d) => (d.abs() % 100) / 100);

  /// Generates Color component values (0-255) for accessibility testing.
  Generator<int> get colorComponent => any.int.map((i) => i.abs() % 256);

  /// Generates RGB color as tuple.
  Generator<(int, int, int)> get rgbColor => any.combine3(
    any.colorComponent,
    any.colorComponent,
    any.colorComponent,
    (r, g, b) => (r, g, b),
  );

  /// Generates Result<T> with configurable success rate.
  Generator<Result<T>> result<T>(
    Generator<T> valueGen, {
    double successRate = 0.8,
  }) => any.double.map((d) {
    final isSuccess = (d.abs() % 1.0) < successRate;
    if (isSuccess) {
      // Generate a default value for success case
      return Success<T>(null as T);
    } else {
      return Failure<T>(NetworkFailure('Test failure'));
    }
  });

  /// Generates AppFailure instances.
  Generator<AppFailure> get appFailure => any.int.map((i) {
    final type = i.abs() % 5;
    final msg = 'Test error message';
    return switch (type) {
      0 => NetworkFailure(msg),
      1 => ServerFailure(msg, statusCode: 500),
      2 => ValidationFailure(msg),
      3 => NotFoundFailure(msg),
      _ => CacheFailure(msg),
    };
  });

  /// Generates PaginatedList<T>.
  Generator<PaginatedList<T>> paginatedList<T>(
    Generator<T> itemGen,
    T defaultItem,
  ) => any.combine3(
    any.customPositiveInt.map((i) => (i % 10) + 1),
    any.customPositiveInt.map((i) => (i % 50) + 1),
    any.customPositiveInt.map((i) => i % 500),
    (page, pageSize, totalItems) {
      final itemCount = pageSize.clamp(0, totalItems - (page - 1) * pageSize);
      final items = List.generate(itemCount.clamp(0, 10), (_) => defaultItem);
      return PaginatedList.fromItems(
        items,
        page: page,
        pageSize: pageSize,
        totalItems: totalItems,
      );
    },
  );

  /// Generates page numbers.
  Generator<int> get pageNumber => any.int.map((i) => (i.abs() % 100) + 1);

  /// Generates page sizes.
  Generator<int> get pageSize => any.int.map((i) => (i.abs() % 50) + 1);

  /// Generates HTTP status codes.
  Generator<int> get httpStatusCode =>
      any.int.map((i) => 200 + (i.abs() % 400));

  /// Generates error HTTP status codes (4xx, 5xx).
  Generator<int> get errorHttpStatusCode =>
      any.int.map((i) => 400 + (i.abs() % 200));

  /// Generates UUIDs.
  Generator<String> get uuid => any.int.map((seed) {
    final r = Random(seed);
    String hex(int len) =>
        List.generate(len, (_) => r.nextInt(16).toRadixString(16)).join();
    return '${hex(8)}-${hex(4)}-${hex(4)}-${hex(12)}';
  });
}

/// Configuration for property tests.
abstract final class PropertyTestConfig {
  /// Default number of iterations for property tests.
  static const int defaultIterations = 100;

  /// Minimum iterations for quick tests.
  static const int minIterations = 50;

  /// Maximum iterations for thorough tests.
  static const int maxIterations = 500;
}
