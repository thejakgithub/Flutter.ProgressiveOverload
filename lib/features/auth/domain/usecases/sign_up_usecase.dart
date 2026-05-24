import '../repositories/auth_repository.dart';

class SignUpUseCase {
  SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _repository.signUpWithEmail(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
