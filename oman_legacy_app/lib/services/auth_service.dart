import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase =
      Supabase.instance.client;

  // LOGIN
  Future<bool> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      await supabase.auth
          .signInWithPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // SIGNUP
  Future<bool> signupWithEmail(
    String email,
    String password,
  ) async {
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // GOOGLE LOGIN
  Future<bool> signInWithGoogle() async {
    try {
      await supabase.auth
          .signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'io.supabase.flutter://login-callback',
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // CURRENT USER
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}


