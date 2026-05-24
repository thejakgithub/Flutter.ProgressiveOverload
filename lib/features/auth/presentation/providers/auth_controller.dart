import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

class AuthController {
  AuthController._(this._signIn, this._signUp);

  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;

  factory AuthController.create() {
    final repository = AuthRepositoryImpl(SupabaseAuthDataSource());
    return AuthController._(
      SignInUseCase(repository),
      SignUpUseCase(repository),
    );
  }

  Future<void> signIn({required String email, required String password}) {
    return _signIn(email: email, password: password);
  }

  Future<void> signInWithGoogle() {
    final repository = AuthRepositoryImpl(SupabaseAuthDataSource());
    return repository.signInWithGoogle();
  }

  Future<void> signInWithApple() {
    final repository = AuthRepositoryImpl(SupabaseAuthDataSource());
    return repository.signInWithApple();
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    final repository = AuthRepositoryImpl(SupabaseAuthDataSource());
    return repository.sendPasswordResetEmail(email: email);
  }

  Future<void> updatePassword({required String newPassword}) {
    final repository = AuthRepositoryImpl(SupabaseAuthDataSource());
    return repository.updatePassword(newPassword: newPassword);
  }

  Future<void> signOut() {
    final repository = AuthRepositoryImpl(SupabaseAuthDataSource());
    return repository.signOut();
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _signUp(fullName: fullName, email: email, password: password);
  }
}
