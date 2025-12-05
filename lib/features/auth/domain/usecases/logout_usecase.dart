import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Use case for user logout.
/// Pure Dart - no external dependencies.
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute logout.
  Future<Result<void>> call() async {
    return _repository.logout();
  }
}
