import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  static GoTrueClient get _auth => SupabaseService.client.auth;

  static User? get currentUser => _auth.currentUser;

  static bool get isSignedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
    debugPrint('Signed in as ${currentUser?.email}');
  }

  // Returns true when the account still needs email confirmation
  static Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signUp(email: email.trim(), password: password);
    debugPrint('Signed up ${response.user?.email}');
    return response.session == null;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    debugPrint('Signed out');
  }

  // Turn auth errors into short messages for the login and sign up screens
  static String errorMessage(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid login credentials')) {
        return 'Wrong email or password.';
      }
      if (message.contains('email not confirmed')) {
        return 'Confirm your email before signing in.';
      }
      if (message.contains('already registered')) {
        return 'An account with this email already exists.';
      }
      if (message.contains('password')) {
        return 'The password is too weak. Use at least 6 characters.';
      }
      if (error.statusCode == '429') {
        return 'Too many attempts. Wait a moment and try again.';
      }
      return error.message;
    }
    if (error.toString().contains('SocketException')) {
      return 'No internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
