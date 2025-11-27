import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coo_list/data/models/profile_model.dart';
import 'package:coo_list/config/supabase_config.dart';

class ProfileRepository {
  final SupabaseClient _supabaseClient = SupabaseConfig.client;

  static const String _profilesTable = 'profiles';

  User _requireUser() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('Felhasználó nincs bejelentkezve');
    }
    return user;
  }

  Future<List<ProfileModel>> getProfiles() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      final response = await _supabaseClient
          .from(_profilesTable)
          .select()
          .eq('user_id', user.id)
          .order('created_at');

      return (response as List)
          .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Nem sikerült a profilok lekérése: $e');
    }
  }

  Future<bool> hasProfiles() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final response = await _supabaseClient
          .from(_profilesTable)
          .select('id')
          .eq('user_id', user.id)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<ProfileModel> createProfile({
    required String name,
    required int colorIndex,
  }) async {
    final user = _requireUser();

    try {
      final profileData = {
        'user_id': user.id,
        'name': name,
        'color': colorIndex,
      };

      final response = await _supabaseClient
          .from(_profilesTable)
          .insert(profileData)
          .select()
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Nem sikerült a profil létrehozása: $e');
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final response = await _supabaseClient
          .from(_profilesTable)
          .update({
            'name': profile.name,
            'color': profile.colorIndex,
          })
          .eq('id', profile.id)
          .select()
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Nem sikerült a profil frissítése: $e');
    }
  }

  Future<void> deleteProfile(String profileId) async {
    try {
      await _supabaseClient.from(_profilesTable).delete().eq('id', profileId);
    } catch (e) {
      throw Exception('Nem sikerült a profil törlése: $e');
    }
  }

  Future<ProfileModel?> getProfileById(String profileId) async {
    try {
      final response = await _supabaseClient
          .from(_profilesTable)
          .select()
          .eq('id', profileId)
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
