import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coo_list/utils/list_type_constants.dart';
import 'package:coo_list/config/supabase_config.dart';

class StatisticsRepository {
  final SupabaseClient _supabaseClient = SupabaseConfig.client;

  User _requireUser() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user;
  }

  Future<List<Map<String, dynamic>>> getItemCountByCategory(
      int listType) async {
    final user = _requireUser();

    try {
      final response = await _supabaseClient
          .from('list_items')
          .select('category_id, categories(id, name)')
          .eq('user_id', user.id)
          .eq('list_type', listType)
          .not('category_id', 'is', null);

      final Map<String, Map<String, dynamic>> categoryCount = {};

      for (final item in response) {
        final categoryData = item['categories'] as Map<String, dynamic>;
        final categoryId = categoryData['id'] as String;

        if (!categoryCount.containsKey(categoryId)) {
          categoryCount[categoryId] = {
            'id': categoryId,
            'name': categoryData['name'],
            'count': 0,
          };
        }

        categoryCount[categoryId]!['count'] =
            (categoryCount[categoryId]!['count'] as int) + 1;
      }

      final result = categoryCount.values.toList();
      result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return result;
    } catch (e) {
      throw Exception('Nem sikerült a kategória statisztikák lekérése: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getItemCountByProfile(int listType) async {
    final user = _requireUser();

    try {
      final response = await _supabaseClient
          .from('list_items')
          .select('profile_id, profiles(id, name, color)')
          .eq('user_id', user.id)
          .eq('list_type', listType);

      final Map<String, Map<String, dynamic>> profileCount = {};

      for (final item in response) {
        final profileData = item['profiles'] as Map<String, dynamic>;
        final profileId = profileData['id'] as String;

        if (!profileCount.containsKey(profileId)) {
          profileCount[profileId] = {
            'id': profileId,
            'name': profileData['name'],
            'color': profileData['color'],
            'count': 0,
          };
        }

        profileCount[profileId]!['count'] =
            (profileCount[profileId]!['count'] as int) + 1;
      }

      final result = profileCount.values.toList();
      result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return result;
    } catch (e) {
      throw Exception('Nem sikerült a profil statisztikák lekérése: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPriceByCategory(int listType) async {
    final user = _requireUser();

    try {
      final response = await _supabaseClient
          .from('list_items')
          .select('price, category_id, categories(id, name)')
          .eq('user_id', user.id)
          .eq('list_type', listType)
          .not('category_id', 'is', null);

      final Map<String, Map<String, dynamic>> categoryPrice = {};

      for (final item in response) {
        final categoryData = item['categories'] as Map<String, dynamic>;
        final categoryId = categoryData['id'] as String;
        final price = item['price'] as num;

        if (!categoryPrice.containsKey(categoryId)) {
          categoryPrice[categoryId] = {
            'id': categoryId,
            'name': categoryData['name'],
            'totalPrice': 0.0,
          };
        }

        categoryPrice[categoryId]!['totalPrice'] =
            (categoryPrice[categoryId]!['totalPrice'] as num) + price;
      }

      final result = categoryPrice.values.toList();
      result.sort(
          (a, b) => (b['totalPrice'] as num).compareTo(a['totalPrice'] as num));

      return result;
    } catch (e) {
      throw Exception('Nem sikerült az ár statisztikák lekérése: $e');
    }
  }

  Future<Map<String, int>> getSpoilageStatistics() async {
    final user = _requireUser();

    try {
      final response = await _supabaseClient
          .from('list_items')
          .select('psdays, last_moved_at')
          .eq('user_id', user.id)
          .eq('list_type', ListType.home)
          .gt('psdays', 0)
          .not('last_moved_at', 'is', null);

      final now = DateTime.now();
      final Map<String, int> result = {
        'spoil_today': 0,
        'spoil_tomorrow': 0,
        'spoil_this_week': 0,
        'spoil_later': 0,
      };

      for (final item in response) {
        final lastMovedAt = DateTime.parse(item['last_moved_at'] as String);
        final psdays = item['psdays'] as int;

        final spoilDate = lastMovedAt.add(Duration(days: psdays));
        final daysUntilSpoiled = spoilDate.difference(now).inDays;

        if (daysUntilSpoiled <= 0) {
          result['spoil_today'] = (result['spoil_today'] ?? 0) + 1;
        } else if (daysUntilSpoiled == 1) {
          result['spoil_tomorrow'] = (result['spoil_tomorrow'] ?? 0) + 1;
        } else if (daysUntilSpoiled <= 7) {
          result['spoil_this_week'] = (result['spoil_this_week'] ?? 0) + 1;
        } else {
          result['spoil_later'] = (result['spoil_later'] ?? 0) + 1;
        }
      }

      return result;
    } catch (e) {
      throw Exception('Nem sikerült a lejárás statisztikák lekérése: $e');
    }
  }
}
