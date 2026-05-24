import '../repositories/auth_repository.dart';

class SignInUseCase {
  SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}
