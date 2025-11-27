import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/data/models/list_item_model.dart';
import 'package:coo_list/data/repositories/list_item_repository.dart';

class ProductProcessingHelper {
  static List<ProductModel> processItemsToProducts(
    List<ListItemModel> items,
    ListItemRepository repository,
  ) {
    return items.map((item) => repository.mapToProductModel(item)).toList();
  }

  static List<ProductModel> sortProductsByDate(
    List<ProductModel> products, {
    required bool ascending,
  }) {
    final sorted = List<ProductModel>.from(products);
    sorted.sort((a, b) {
      final DateTime? dateA = a.lastMovedAt;
      final DateTime? dateB = b.lastMovedAt;

      if (dateA == null && dateB == null) {
        return a.name.compareTo(b.name);
      } else if (dateA == null) {
        return ascending ? -1 : 1;
      } else if (dateB == null) {
        return ascending ? 1 : -1;
      }

      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    return sorted;
  }

  static Map<String, String> buildProductIdMapping(
    List<ProductModel> products,
    List<ListItemModel> originalItems,
    ListItemRepository repository,
  ) {
    final Map<String, ListItemModel> itemsById = {};
    for (final item in originalItems) {
      itemsById[item.id] = item;
    }

    final Map<String, String> productIds = {};

    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      String? matchedId;

      for (final entry in itemsById.entries) {
        final item = entry.value;
        final itemProduct = repository.mapToProductModel(item);

        if (itemProduct.name == product.name &&
            itemProduct.price == product.price &&
            itemProduct.weight == product.weight &&
            itemProduct.db == product.db &&
            itemProduct.lastMovedAt == product.lastMovedAt) {
          matchedId = entry.key;
          itemsById.remove(entry.key);
          break;
        }
      }

      if (matchedId == null && itemsById.isNotEmpty) {
        for (final entry in itemsById.entries) {
          final item = entry.value;
          final itemProduct = repository.mapToProductModel(item);

          if (itemProduct.name == product.name &&
              itemProduct.price == product.price &&
              itemProduct.weight == product.weight) {
            matchedId = entry.key;
            itemsById.remove(entry.key);
            break;
          }
        }
      }

      if (matchedId != null) {
        productIds[i.toString()] = matchedId;
      }
    }

    return productIds;
  }

  static ({
    Map<String, ProductModel> productItems,
    List<String> orderedProductIds,
  }) buildProductItemsMap(
    List<ProductModel> products,
    Map<String, String> productIds,
  ) {
    final Map<String, ProductModel> productItemsMap = {};
    final List<String> orderedIds = [];

    for (int i = 0; i < products.length; i++) {
      final String indexStr = i.toString();
      if (productIds.containsKey(indexStr)) {
        final String id = productIds[indexStr]!;
        productItemsMap[id] = products[i];
        orderedIds.add(id);
      }
    }

    return (
      productItems: productItemsMap,
      orderedProductIds: orderedIds,
    );
  }
}
