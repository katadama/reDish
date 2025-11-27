import 'package:equatable/equatable.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/data/models/list_item_model.dart';

abstract class CategoryProductsEvent extends Equatable {
  const CategoryProductsEvent();

  @override
  List<Object> get props => [];
}

class LoadCategoryProducts extends CategoryProductsEvent {
  final String categoryId;
  final int listType;

  const LoadCategoryProducts(this.categoryId, {this.listType = 1});

  @override
  List<Object> get props => [categoryId, listType];
}

class UpdateItemListType extends CategoryProductsEvent {
  final String itemId;
  final int newListType;
  final String categoryId;
  final int currentListType;
  final String profileId;
  final bool duplicate;
  final bool slice;
  final bool takeOne;

  const UpdateItemListType({
    required this.itemId,
    required this.newListType,
    required this.categoryId,
    required this.currentListType,
    required this.profileId,
    this.duplicate = false,
    this.slice = false,
    this.takeOne = false,
  });

  @override
  List<Object> get props => [
        itemId,
        newListType,
        categoryId,
        currentListType,
        profileId,
        duplicate,
        slice,
        takeOne,
      ];
}

class ProductsUpdated extends CategoryProductsEvent {
  final List<ListItemModel> items;

  const ProductsUpdated(this.items);

  @override
  List<Object> get props => [items];
}

class SwipeItem extends CategoryProductsEvent {
  final String productId;
  final SwipeDirection direction;
  final int targetListType;

  const SwipeItem({
    required this.productId,
    required this.direction,
    required this.targetListType,
  });

  @override
  List<Object> get props => [productId, direction, targetListType];
}

class ProcessSwipedItems extends CategoryProductsEvent {
  const ProcessSwipedItems();
}

class InitializeProducts extends CategoryProductsEvent {
  final List<ProductModel> products;
  final Map<String, String> productIds;

  const InitializeProducts({
    required this.products,
    required this.productIds,
  });

  @override
  List<Object> get props => [products, productIds];
}

class AddItem extends CategoryProductsEvent {
  final String productId;
  final ProductModel product;

  const AddItem({
    required this.productId,
    required this.product,
  });

  @override
  List<Object> get props => [productId, product];
}

class RemoveItem extends CategoryProductsEvent {
  final String productId;

  const RemoveItem({required this.productId});

  @override
  List<Object> get props => [productId];
}
