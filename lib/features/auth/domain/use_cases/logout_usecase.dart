import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_base_2025/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user logout.
/// Pure Dart - no external dependencies.
class LogoutUseCase {

  LogoutUseCase(this._repository);
  final AuthRepository _repository;

  /// Execute logout.
  Future<Result<void>> call() async => _repository.logout();
}
