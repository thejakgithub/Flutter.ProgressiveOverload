import '../../domain/repositories/auth_repository.dart';
import '../datasources/supabase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final SupabaseAuthDataSource _dataSource;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _dataSource.signInWithEmail(email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() {
    return _dataSource.signInWithGoogle();
  }

  @override
  Future<void> signInWithApple() {
    return _dataSource.signInWithApple();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _dataSource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updatePassword({required String newPassword}) {
    return _dataSource.updatePassword(newPassword: newPassword);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _dataSource.signUpWithEmail(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
