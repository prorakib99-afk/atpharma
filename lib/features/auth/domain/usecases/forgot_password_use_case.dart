import '../../../../core/error/app_result.dart';
import '../repositories/auth_repository.dart';

final class ForgotPasswordUseCase {
  const ForgotPasswordUseCase({required this._repository});
  final AuthRepository _repository;
  Future<AppResult<String>> call(String email) =>
      _repository.forgotPassword(email: email.trim());
}
