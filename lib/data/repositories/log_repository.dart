import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coo_list/config/app_router.dart';
import 'package:coo_list/config/supabase_config.dart';

class LogRepository {
  final SupabaseClient _supabaseClient = SupabaseConfig.client;
  static const String _logsTable = 'logs';

  Future<void> logEvent({
    required String logName,
    required Map<String, dynamic> additionalData,
  }) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final prefs = await SharedPreferences.getInstance();
    final profileId = prefs.getString(AppRouter.lastSelectedProfileKey);
    if (profileId == null) {
      throw Exception('No active profile found');
    }

    final logData = {
      'user_id': user.id,
      'profile_id': profileId,
      'log_name': logName,
      'additional_data': additionalData,
    };

    await _supabaseClient.from(_logsTable).insert(logData);
  }
}
