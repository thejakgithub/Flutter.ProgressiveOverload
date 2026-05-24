import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_bootstrap.dart';

class SupabaseAuthDataSource {
  static const _redirectUrl = String.fromEnvironment('SUPABASE_REDIRECT_URL');

  SupabaseClient get _client {
    final client = SupabaseBootstrap.client;
    if (client == null) {
      throw StateError(
        'Supabase is not configured. Run with --dart-define=SUPABASE_URL and --dart-define=SUPABASE_ANON_KEY',
      );
    }
    return client;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: _redirectUrl.isEmpty ? null : _redirectUrl,
      data: {'full_name': fullName},
    );
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _redirectUrl.isEmpty ? null : _redirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: _redirectUrl.isEmpty ? null : _redirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: _redirectUrl.isEmpty ? null : _redirectUrl,
    );
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
