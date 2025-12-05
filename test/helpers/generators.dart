import 'package:glados/glados.dart';

import 'package:flutter_base_2025/features/auth/data/models/user_dto.dart';
import 'package:flutter_base_2025/features/auth/domain/entities/user.dart';

import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/generics/paginated_list.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// Custom generators for property-based testing with Glados.
extension CustomGenerators on Any {
  /// Generates non-empty strings with letters only.
  Arbitrary<String> get nonEmptyLetters =>
      any.letterOrDigits.where((s) => s.isNotEmpty && s.length <= 50);

  /// Generates valid email addresses.
  Arbitrary<String> get email => any.nonEmptyLetters.map((s) => '$s@test.com');

  /// Generates valid passwords (6+ characters).
  Arbitrary<String> get password =>
      any.letterOrDigits.where((s) => s.length >= 6 && s.length <= 50);

  /// Generates User entities.
  Arbitrary<User> get user => combine4(
        any.nonEmptyLetters,
        any.email,
        any.nonEmptyLetters,
        any.dateTime,
        (id, email, name, createdAt) => User(
          id: id,
          email: email,
          name: name,
          createdAt: createdAt,
        ),
      );

  /// Generates UserDto instances.
  Arbitrary<UserDto> get userDto => combine4(
        any.nonEmptyLetters,
        any.email,
        any.nonEmptyLetters,
        any.dateTime,
        (id, email, name, createdAt) => UserDto(
          id: id,
          email: email,
          name: name,
          createdAt: createdAt,
        ),
      );

  /// Generates nullable strings.
  Arbitrary<String?> get nullableString =>
      any.bool.flatMap((isNull) => isNull ? any.always(null) : any.letters);

  /// Generates nullable DateTimes.
  Arbitrary<DateTime?> get nullableDateTime =>
      any.bool.flatMap((isNull) => isNull ? any.always(null) : any.dateTime);

  /// Generates positive integers.
  Arbitrary<int> get positiveInt => any.int.where((i) => i > 0);

  /// Generates non-negative integers.
  Arbitrary<int> get nonNegativeInt => any.int.where((i) => i >= 0);

  /// Generates percentages (0.0 to 1.0).
  Arbitrary<double> get percentage =>
      any.double.map((d) => (d.abs() % 100) / 100);

  /// Generates Color component values (0-255) for accessibility testing.
  Arbitrary<int> get colorComponent => any.int.map((i) => i.abs() % 256);

  /// Generates RGB color as tuple.
  Arbitrary<(int, int, int)> get rgbColor => combine3(
        any.colorComponent,
        any.colorComponent,
        any.colorComponent,
        (r, g, b) => (r, g, b),
      );

  /// Generates Result<T> with configurable success rate.
  Arbitrary<Result<T>> result<T>(
    Arbitrary<T> valueGen, {
    double successRate = 0.8,
  }) {
    return any.double.flatMap((d) {
      final isSuccess = (d.abs() % 1.0) < successRate;
      if (isSuccess) {
        return valueGen.map((v) => Success(v));
      } else {
        return any.appFailure.map((f) => Failure<T>(f));
      }
    });
  }

  /// Generates AppFailure instances.
  Arbitrary<AppFailure> get appFailure {
    return any.int.flatMap((i) {
      final type = i.abs() % 5;
      return any.letters.map((msg) {
        return switch (type) {
          0 => NetworkFailure(msg),
          1 => ServerFailure(msg, statusCode: 500),
          2 => ValidationFailure(msg),
          3 => NotFoundFailure(msg),
          _ => CacheFailure(msg),
        };
      });
    });
  }

  /// Generates PaginatedList<T>.
  Arbitrary<PaginatedList<T>> paginatedList<T>(Arbitrary<T> itemGen) {
    return combine3(
      any.int.where((i) => i > 0 && i <= 10),
      any.int.where((i) => i > 0 && i <= 50),
      any.int.where((i) => i >= 0 && i <= 500),
      (page, pageSize, totalItems) {
        final itemCount = pageSize.clamp(0, totalItems - (page - 1) * pageSize);
        return itemGen.list.map((items) {
          final actualItems = items.take(itemCount.clamp(0, items.length)).toList();
          return PaginatedList.fromItems(
            actualItems,
            page: page,
            pageSize: pageSize,
            totalItems: totalItems,
          );
        });
      },
    ).flatMap((gen) => gen);
  }

  /// Generates page numbers.
  Arbitrary<int> get pageNumber => any.int.where((i) => i > 0 && i <= 100);

  /// Generates page sizes.
  Arbitrary<int> get pageSize => any.int.where((i) => i > 0 && i <= 50);

  /// Generates HTTP status codes.
  Arbitrary<int> get httpStatusCode => any.int.map((i) => 200 + (i.abs() % 400));

  /// Generates error HTTP status codes (4xx, 5xx).
  Arbitrary<int> get errorHttpStatusCode =>
      any.int.map((i) => 400 + (i.abs() % 200));

  /// Generates UUIDs.
  Arbitrary<String> get uuid => combine4(
        any.letterOrDigits.where((s) => s.length == 8),
        any.letterOrDigits.where((s) => s.length == 4),
        any.letterOrDigits.where((s) => s.length == 4),
        any.letterOrDigits.where((s) => s.length == 12),
        (a, b, c, d) => '$a-$b-$c-$d',
      );
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
