import 'package:flutter_base_2025/core/constants/validation_patterns.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_base_2025/features/auth/domain/entities/user.dart';
import 'package:flutter_base_2025/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user login.
/// Pure Dart - no external dependencies.
class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  /// Execute login with email and password.
  Future<Result<User>> call({
    required String email,
    required String password,
  }) async {
    // Validate input
    final validationResult = _validateInput(email, password);
    if (validationResult != null) {
      return validationResult;
    }

    return _repository.login(email, password);
  }

  Result<User>? _validateInput(String email, String password) {
    if (email.isEmpty) {
      return const Failure(
        ValidationFailure(
          'Email is required',
          fieldErrors: {
            'email': ['Email is required'],
          },
        ),
      );
    }

    if (!_isValidEmail(email)) {
      return const Failure(
        ValidationFailure(
          'Invalid email format',
          fieldErrors: {
            'email': ['Invalid email format'],
          },
        ),
      );
    }

    if (password.isEmpty) {
      return const Failure(
        ValidationFailure(
          'Password is required',
          fieldErrors: {
            'password': ['Password is required'],
          },
        ),
      );
    }

    if (password.length < 6) {
      return const Failure(
        ValidationFailure(
          'Password too short',
          fieldErrors: {
            'password': ['Password must be at least 6 characters'],
          },
        ),
      );
    }

    return null;
  }

  /// Uses shared ValidationPatterns to avoid regex duplication.
  bool _isValidEmail(String email) => ValidationPatterns.email.hasMatch(email);
}
