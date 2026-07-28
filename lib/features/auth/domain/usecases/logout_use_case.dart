import '../../../../core/error/app_result.dart';
import '../repositories/auth_repository.dart';

final class LogoutUseCase {
  const LogoutUseCase({required this._repository});

  final AuthRepository _repository;

  Future<AppResult<void>> call() => _repository.logout();
}
