import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static Session? get currentSession => _client.auth.currentSession;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  static Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'app.hostelmess.mess://login-callback',
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}