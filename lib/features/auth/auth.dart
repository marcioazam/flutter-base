/// Auth feature barrel file.
///
/// Export all public APIs from the auth feature.
library;

// Data layer
export 'data/data_sources/auth_remote_datasource.dart';
export 'data/dtos/auth_response_dto.dart';
export 'data/dtos/user_dto.dart';
export 'data/repositories/auth_repository_impl.dart';

// Domain layer
export 'domain/entities/permission.dart';
export 'domain/entities/user.dart';
export 'domain/entities/user_role.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/repositories/authorization_repository.dart';
export 'domain/use_cases/login_usecase.dart';
export 'domain/use_cases/logout_usecase.dart';

// Presentation layer
export 'presentation/pages/login_page.dart';
export 'presentation/providers/auth_provider.dart';
