import 'package:supabase_flutter/supabase_flutter.dart';

import 'backend.dart';

/// Result of a sign-up attempt.
enum SignUpOutcome { signedIn, confirmEmail }

/// Thin wrapper over Supabase Auth (email + password).
abstract final class AuthService {
  static User? get currentUser =>
      Backend.isAvailable ? Backend.client.auth.currentUser : null;

  static bool get isSignedIn => currentUser != null;

  /// Emits whenever the user signs in or out. Empty stream when offline.
  static Stream<AuthState> get changes => Backend.isAvailable
      ? Backend.client.auth.onAuthStateChange
      : const Stream.empty();

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await Backend.client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Creates an account. If the project requires email confirmation, no
  /// session is returned and the user must confirm before signing in.
  static Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) async {
    final res = await Backend.client.auth.signUp(
      email: email.trim(),
      password: password,
    );
    return res.session != null
        ? SignUpOutcome.signedIn
        : SignUpOutcome.confirmEmail;
  }

  static Future<void> signOut() => Backend.client.auth.signOut();

  /// Human-readable message for any auth / network error.
  static String describeError(Object error) {
    if (error is AuthException) return error.message;
    return 'Could not reach the server. Check your connection and try again.';
  }
}
