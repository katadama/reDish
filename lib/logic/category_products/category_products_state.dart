import 'package:equatable/equatable.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

abstract class CategoryProductsState extends Equatable {
  const CategoryProductsState();

  @override
  List<Object?> get props => [];
}

class CategoryProductsInitial extends CategoryProductsState {
  const CategoryProductsInitial();
}

class CategoryProductsLoading extends CategoryProductsState {
  const CategoryProductsLoading();
}

class CategoryProductsLoaded extends CategoryProductsState {
  final List<ProductModel> products;
  final Map<String, String> productIds;
  final Set<String> swipedItems;
  final Map<String, ProductModel> productItems;
  final List<String> orderedProductIds;
  final bool isInitialized;
  final bool hasContextMenuAction;
  final Map<String, String> productIdToProfileId;

  const CategoryProductsLoaded({
    required this.products,
    required this.productIds,
    this.swipedItems = const {},
    this.productItems = const {},
    this.orderedProductIds = const [],
    this.isInitialized = false,
    this.hasContextMenuAction = false,
    this.productIdToProfileId = const {},
  });

  CategoryProductsLoaded copyWith({
    List<ProductModel>? products,
    Map<String, String>? productIds,
    Set<String>? swipedItems,
    Map<String, ProductModel>? productItems,
    List<String>? orderedProductIds,
    bool? isInitialized,
    bool? hasContextMenuAction,
    Map<String, String>? productIdToProfileId,
  }) {
    return CategoryProductsLoaded(
      products: products ?? this.products,
      productIds: productIds ?? this.productIds,
      swipedItems: swipedItems ?? this.swipedItems,
      productItems: productItems ?? this.productItems,
      orderedProductIds: orderedProductIds ?? this.orderedProductIds,
      isInitialized: isInitialized ?? this.isInitialized,
      hasContextMenuAction: hasContextMenuAction ?? this.hasContextMenuAction,
      productIdToProfileId: productIdToProfileId ?? this.productIdToProfileId,
    );
  }

  @override
  List<Object?> get props => [
        products,
        productIds,
        swipedItems,
        productItems,
        orderedProductIds,
        isInitialized,
        hasContextMenuAction,
        productIdToProfileId,
      ];
}

class CategoryProductsError extends CategoryProductsState {
  final String message;

  const CategoryProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryProductsItemSwiped extends CategoryProductsState {
  final String productId;
  final SwipeDirection direction;
  final int targetListType;
  final CategoryProductsLoaded previousState;

  const CategoryProductsItemSwiped({
    required this.productId,
    required this.direction,
    required this.targetListType,
    required this.previousState,
  });

  @override
  List<Object?> get props =>
      [productId, direction, targetListType, previousState];
}

class CategoryProductsAnimating extends CategoryProductsState {
  final CategoryProductsLoaded baseState;
  final Set<String> itemsBeingRemoved;
  final Set<String> itemsBeingAdded;

  const CategoryProductsAnimating({
    required this.baseState,
    this.itemsBeingRemoved = const {},
    this.itemsBeingAdded = const {},
  });

  @override
  List<Object?> get props => [baseState, itemsBeingRemoved, itemsBeingAdded];
}
