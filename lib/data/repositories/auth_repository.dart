import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coo_list/config/supabase_config.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient = SupabaseConfig.client;

  Future<void> signUp(String email, String password) async {
    try {
      await _supabaseClient.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      if (e is Exception) {
        throw Exception(e.toString().replaceFirst('Exception: ', ''));
      }
      throw Exception(e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      if (e is Exception) {
        throw Exception(e.toString().replaceFirst('Exception: ', ''));
      }
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }
}
