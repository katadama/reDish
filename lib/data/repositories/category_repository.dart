import 'package:coo_list/config/list_type_constants.dart';
import 'package:coo_list/data/models/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coo_list/config/supabase_config.dart';
import 'dart:async';

class CategoryRepository {
  final SupabaseClient _supabaseClient = SupabaseConfig.client;

  User _requireUser() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('Felhasználó nincs bejelentkezve');
    }
    return user;
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _supabaseClient.from('categories').select('*');

      return response
          .map((category) => CategoryModel.fromJson(category))
          .toList()
          .cast<CategoryModel>();
    } catch (e) {
      throw Exception('Nem sikerült a kategóriák lekérése: $e');
    }
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final response = await _supabaseClient
          .from('categories')
          .select()
          .eq('id', id)
          .single();

      return CategoryModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<CategoryModel?> getCategoryByName(String name) async {
    try {
      final response = await _supabaseClient
          .from('categories')
          .select()
          .eq('name', name)
          .single();

      return CategoryModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<CategoryModel>> getCategoriesWithItemCounts(int listType) async {
    final user = _requireUser();

    try {
      final categories = await getCategories();

      final response = await _supabaseClient
          .from('list_items')
          .select('category_id, categories(id, name)')
          .eq('user_id', user.id)
          .eq('list_type', listType)
          .not('category_id', 'is', null);

      final Map<String, int> categoryCount = {};
      int totalItems = 0;

      for (final item in response) {
        final categoryData = item['categories'] as Map<String, dynamic>;
        final categoryId = categoryData['id'] as String;

        categoryCount[categoryId] = (categoryCount[categoryId] ?? 0) + 1;
        totalItems++;
      }

      final updatedCategories = categories.map((category) {
        final count = categoryCount[category.id] ?? 0;
        final percentage = totalItems > 0 ? (count / totalItems) * 100 : 0.0;

        return category.copyWith(
          itemCount: count,
          percentage: percentage,
        );
      }).toList();

      updatedCategories.sort((a, b) {
        return b.updatedAt.compareTo(a.updatedAt);
      });

      return updatedCategories;
    } catch (e) {
      throw Exception(
          'Nem sikerült a kategóriák lekérése termék számokkal: $e');
    }
  }

  Future<List<CategoryModel>> getCategoriesWithShoppingCounts() async {
    return getCategoriesWithItemCounts(ListType.shopping);
  }

  Future<List<CategoryModel>> getCategoriesWithHomeCounts() async {
    return getCategoriesWithItemCounts(ListType.home);
  }

  Stream<List<CategoryModel>> streamCategoriesWithItemCounts(int listType) {
    _requireUser();

    final controller = StreamController<List<CategoryModel>>();

    Future<void> fetchAndEmit() async {
      try {
        final categories = await getCategoriesWithItemCounts(listType);
        if (!controller.isClosed) {
          controller.add(categories);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    fetchAndEmit();

    final subscription = _supabaseClient
        .channel('public:list_items:categories')
        .onPostgresChanges(
          schema: 'public',
          table: 'list_items',
          event: PostgresChangeEvent.all,
          callback: (payload) {
            fetchAndEmit();
          },
        )
        .subscribe();

    controller.onCancel = () {
      subscription.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  Stream<List<CategoryModel>> streamCategoriesWithShoppingCounts() {
    return streamCategoriesWithItemCounts(ListType.shopping);
  }

  Stream<List<CategoryModel>> streamCategoriesWithHomeCounts() {
    return streamCategoriesWithItemCounts(ListType.home);
  }

  Future<List<String>> getCategoryNames() async {
    try {
      final response = await _supabaseClient.from('categories').select('name');
      return (response as List).map((item) => item['name'] as String).toList();
    } catch (e) {
      throw Exception('Nem sikerült a kategória nevek lekérése: $e');
    }
  }
}
