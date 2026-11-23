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
}
