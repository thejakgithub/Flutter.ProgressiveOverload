abstract class AuthRepository {
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> updatePassword({required String newPassword});

  Future<void> signOut();

  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  });
}
