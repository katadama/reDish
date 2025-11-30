import 'package:coo_list/utils/list_type_constants.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/data/models/category_model.dart';
import 'package:coo_list/data/models/list_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coo_list/config/supabase_config.dart';
import 'dart:async';

class ListItemRepository {
  final SupabaseClient _supabaseClient = SupabaseConfig.client;

  @Deprecated('Use ListType.shopping instead')
  static const int listTypeShopping = ListType.shopping;
  @Deprecated('Use ListType.home instead')
  static const int listTypeHome = ListType.home;
  @Deprecated('Use ListType.bin instead')
  static const int listTypeBin = ListType.bin;

  User _requireUser() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('Felhasználó nincs bejelentkezve');
    }
    return user;
  }

  Stream<List<ListItemModel>> _createStream(
    Future<List<ListItemModel>> Function() fetchFunction,
    String channelName,
  ) {
    _requireUser();

    final controller = StreamController<List<ListItemModel>>();

    Future<void> fetchAndEmit() async {
      try {
        final items = await fetchFunction();
        if (!controller.isClosed) {
          controller.add(items);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    fetchAndEmit();

    final subscription = _supabaseClient
        .channel(channelName)
        .onPostgresChanges(
          schema: 'public',
          table: 'list_items',
          event: PostgresChangeEvent.all,
          callback: (_) => fetchAndEmit(),
        )
        .subscribe();

    controller.onCancel = () {
      subscription.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  Future<List<ListItemModel>> getItemsByCategory(String categoryId) async {
    final user = _requireUser();

    try {
      final response = await _supabaseClient
          .from('list_items')
          .select('*, categories!inner(name), profiles:profile_id(name, color)')
          .eq('user_id', user.id)
          .eq('category_id', categoryId);

      return response.map((item) => ListItemModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Nem sikerült a termékek lekérése kategória szerint: $e');
    }
  }

  Future<List<ListItemModel>> getItemsByCategoryAndListType(
      String categoryId, int listType) async {
    final user = _requireUser();

    try {
      final response = await _supabaseClient
          .from('list_items')
          .select('*, categories!inner(name), profiles:profile_id(name, color)')
          .eq('user_id', user.id)
          .eq('category_id', categoryId)
          .eq('list_type', listType);

      return response.map((item) => ListItemModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception(
          'Nem sikerült a termékek lekérése kategória és lista típus szerint: $e');
    }
  }

  Future<List<CategoryModel>> getCategoriesWithHomeItems() async {
    final user = _requireUser();

    try {
      final response = await _supabaseClient
          .from('list_items')
          .select('categories:category_id(*)')
          .eq('user_id', user.id)
          .eq('list_type', ListType.home)
          .not('category_id', 'is', null);

      final List<CategoryModel> categories = [];
      final Set<String> processedCategoryIds = {};

      for (final item in response) {
        final categoryData = item['categories'] as Map<String, dynamic>;
        final String categoryId = categoryData['id'] as String;

        if (!processedCategoryIds.contains(categoryId)) {
          processedCategoryIds.add(categoryId);
          categories.add(CategoryModel.fromJson(categoryData));
        }
      }

      return categories;
    } catch (e) {
      throw Exception(
          'Nem sikerült a kategóriák lekérése otthoni termékekkel: $e');
    }
  }

  ProductModel mapToProductModel(ListItemModel item) {
    return ProductModel(
      name: item.name,
      category: item.categoryName ?? '',
      price: item.price.toInt(),
      weight: item.weight,
      db: item.db,
      spoilage: item.psdays,
      lastMovedAt: item.lastMovedAt,
      profileName: item.profileName,
      profileColorIndex: item.profileColorIndex,
    );
  }

  Future<ListItemModel?> getItemById(String id) async {
    try {
      final response = await _supabaseClient
          .from('list_items')
          .select('*, categories(name), profiles:profile_id(name, color)')
          .eq('id', id)
          .single();

      return ListItemModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<ProductModel>> getAllHomeInventoryForRecipes() async {
    final user = _requireUser();

    try {
      final excludedCategories = ['Háztartás', 'Szépségápolás'];

      final response = await _supabaseClient
          .from('list_items')
          .select('*, categories(name, id), profiles:profile_id(name, color)')
          .eq('user_id', user.id)
          .eq('list_type', ListType.home);

      final filteredResponse = response.where((item) {
        final categoryData = item['categories'] as Map<String, dynamic>?;
        final categoryName = categoryData?['name'] as String?;
        return categoryName != null &&
            !excludedCategories.contains(categoryName);
      }).toList();

      return filteredResponse.map<ProductModel>((item) {
        final listItemModel = ListItemModel.fromJson(item);
        return mapToProductModel(listItemModel);
      }).toList();
    } catch (e) {
      throw Exception(
          'Nem sikerült az otthoni készlet termékek lekérése receptekhez: $e');
    }
  }

  Future<bool> updateItemListType(
      String itemId, int newListType, String profileId) async {
    final user = _requireUser();

    try {
      await _supabaseClient
          .from('list_items')
          .update({
            'list_type': newListType,
            'profile_id': profileId,
          })
          .eq('id', itemId)
          .eq('user_id', user.id);
      return true;
    } catch (e) {
      throw Exception('Nem sikerült a termék lista típusának frissítése: $e');
    }
  }

  Future<List<ListItemModel>> getBinItems() async {
    final user = _requireUser();

    try {
      final response = await _supabaseClient
          .from('list_items')
          .select('*, categories(name), profiles:profile_id(name, color)')
          .eq('user_id', user.id)
          .eq('list_type', ListType.bin);

      return response.map((item) => ListItemModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Nem sikerült a kuka termékek lekérése: $e');
    }
  }

  Stream<List<ListItemModel>> streamItemsByCategoryAndListType(
      String categoryId, int listType) {
    return _createStream(
      () => getItemsByCategoryAndListType(categoryId, listType),
      'public:list_items',
    );
  }

  Stream<List<ListItemModel>> streamBinItems() {
    return _createStream(
      () => getBinItems(),
      'public:list_items:bin',
    );
  }

  Future<List<String>> createMultipleItems(
      String itemId, String profileId) async {
    _requireUser();

    try {
      final originalItem = await getItemById(itemId);
      if (originalItem == null) {
        throw Exception('Termék nem található');
      }

      final int originalQuantity = originalItem.db;

      if (originalQuantity <= 1 || originalQuantity >= 25) {
        if (originalQuantity <= 1) {
          final newItemId =
              await sliceItem(itemId, profileId, isDuplicate: true);
          return newItemId != null ? [newItemId] : [];
        } else {
          return [];
        }
      }

      final List<String> newItemIds = [];

      final List<Map<String, dynamic>> newItems = [];
      for (int i = 0; i < originalQuantity - 1; i++) {
        final newItemJson = originalItem.toJson();

        newItemJson.remove('id');

        newItemJson['db'] = 1;

        newItemJson['profile_id'] = profileId;

        newItems.add(newItemJson);
      }

      if (newItems.isNotEmpty) {
        final response = await _supabaseClient
            .from('list_items')
            .insert(newItems)
            .select('id');

        for (final item in response) {
          newItemIds.add(item['id'] as String);
        }
      }

      await _supabaseClient
          .from('list_items')
          .update({'db': 1, 'profile_id': profileId}).eq('id', itemId);

      return newItemIds;
    } catch (e) {
      throw Exception('Nem sikerült több termék létrehozása: $e');
    }
  }

  Future<String?> sliceItem(String itemId, String profileId,
      {bool isDuplicate = false, bool isTakeOne = false}) async {
    _requireUser();

    try {
      final originalItem = await getItemById(itemId);
      if (originalItem == null) {
        throw Exception('Termék nem található');
      }

      if (isDuplicate) {
        return await _duplicateItem(itemId, profileId, originalItem);
      } else if (isTakeOne) {
        return await _takeOneItem(itemId, profileId, originalItem);
      } else {
        return await _sliceItem(itemId, profileId, originalItem);
      }
    } catch (e) {
      throw Exception('Nem sikerült a termék kettévágása/duplikálása: $e');
    }
  }

  Future<String?> _duplicateItem(
      String itemId, String profileId, ListItemModel originalItem) async {
    final newItemJson = originalItem.toJson();
    newItemJson.remove('id');
    newItemJson['profile_id'] = profileId;

    await _supabaseClient
        .from('list_items')
        .update({'profile_id': profileId}).eq('id', itemId);

    final response = await _supabaseClient
        .from('list_items')
        .insert(newItemJson)
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<String?> _takeOneItem(
      String itemId, String profileId, ListItemModel originalItem) async {
    final originalQuantity = originalItem.db;

    if (originalQuantity <= 1) {
      return await _duplicateItem(itemId, profileId, originalItem);
    }

    final newItemJson = originalItem.toJson();
    newItemJson.remove('id');
    newItemJson['profile_id'] = profileId;
    newItemJson['db'] = 1;

    await _supabaseClient.from('list_items').update({
      'db': originalQuantity - 1,
      'profile_id': profileId,
    }).eq('id', itemId);

    final response = await _supabaseClient
        .from('list_items')
        .insert(newItemJson)
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<String?> _sliceItem(
      String itemId, String profileId, ListItemModel originalItem) async {
    final originalQuantity = originalItem.db;

    if (originalQuantity <= 1) {
      return await _duplicateItem(itemId, profileId, originalItem);
    }

    final halfQuantity = originalQuantity ~/ 2;
    final remainingQuantity = originalQuantity - halfQuantity;

    final newItemJson = originalItem.toJson();
    newItemJson.remove('id');
    newItemJson['profile_id'] = profileId;
    newItemJson['db'] = halfQuantity;

    await _supabaseClient.from('list_items').update({
      'db': remainingQuantity,
      'profile_id': profileId,
    }).eq('id', itemId);

    final response = await _supabaseClient
        .from('list_items')
        .insert(newItemJson)
        .select('id')
        .single();

    return response['id'] as String;
  }
}
