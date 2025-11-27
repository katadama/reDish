import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/data/repositories/list_item_repository.dart';
import 'package:coo_list/utils/product_processing_helper.dart';

import 'package:coo_list/logic/category_products/category_products_event.dart';
import 'package:coo_list/logic/category_products/category_products_state.dart';

class CategoryProductsBloc
    extends Bloc<CategoryProductsEvent, CategoryProductsState> {
  final ListItemRepository listItemRepository;
  StreamSubscription? _itemsSubscription;

  CategoryProductsBloc({required this.listItemRepository})
      : super(const CategoryProductsInitial()) {
    on<LoadCategoryProducts>(_onLoadCategoryProducts);
    on<UpdateItemListType>(_onUpdateItemListType);
    on<ProductsUpdated>(_onProductsUpdated);
    on<SwipeItem>(_onSwipeItem);
    on<ProcessSwipedItems>(_onProcessSwipedItems);
    on<InitializeProducts>(_onInitializeProducts);
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
  }

  Future<void> _onLoadCategoryProducts(
    LoadCategoryProducts event,
    Emitter<CategoryProductsState> emit,
  ) async {
    emit(const CategoryProductsLoading());

    try {
      await _itemsSubscription?.cancel();

      _itemsSubscription = listItemRepository
          .streamItemsByCategoryAndListType(event.categoryId, event.listType)
          .listen(
        (items) => add(ProductsUpdated(items)),
        onError: (error) {
          emit(CategoryProductsError(
              'Nem sikerült betölteni a termékeket: $error'));
        },
      );
    } catch (e) {
      emit(CategoryProductsError('Nem sikerült betölteni a termékeket: $e'));
    }
  }

  void _onProductsUpdated(
    ProductsUpdated event,
    Emitter<CategoryProductsState> emit,
  ) {
    if (event.items.isEmpty) {
      emit(const CategoryProductsLoaded(
        products: [],
        productIds: {},
        productIdToProfileId: {},
      ));
      return;
    }

    final products = ProductProcessingHelper.processItemsToProducts(
      event.items,
      listItemRepository,
    );

    final sortedProducts = ProductProcessingHelper.sortProductsByDate(
      products,
      ascending: true,
    );

    final productIds = ProductProcessingHelper.buildProductIdMapping(
      sortedProducts,
      event.items,
      listItemRepository,
    );

    final currentLoadedState = _getCurrentLoadedState();

    final result = ProductProcessingHelper.buildProductItemsMap(
      sortedProducts,
      productIds,
    );

    final Map<String, String> productIdToProfileId = {};
    for (final item in event.items) {
      productIdToProfileId[item.id] = item.profileId;
    }

    emit(CategoryProductsLoaded(
      products: sortedProducts,
      productIds: productIds,
      productItems: result.productItems,
      orderedProductIds: result.orderedProductIds,
      swipedItems: currentLoadedState?.swipedItems ?? {},
      isInitialized: currentLoadedState?.isInitialized ?? true,
      productIdToProfileId: productIdToProfileId,
    ));

    if (currentLoadedState?.swipedItems.isNotEmpty ?? false) {
      add(const ProcessSwipedItems());
    }
  }

  CategoryProductsLoaded? _getCurrentLoadedState() {
    if (state is CategoryProductsLoaded) {
      return state as CategoryProductsLoaded;
    } else if (state is CategoryProductsAnimating) {
      return (state as CategoryProductsAnimating).baseState;
    }
    return null;
  }

  Future<void> _onUpdateItemListType(
    UpdateItemListType event,
    Emitter<CategoryProductsState> emit,
  ) async {
    try {
      if (event.duplicate && event.slice) {
        await _onCreateMultipleItems(event, emit);
      } else if (event.duplicate) {
        await _onDuplicateItem(event, emit);
      } else if (event.slice) {
        await _onSliceItem(event, emit);
      } else if (event.takeOne) {
        await _onTakeOneItem(event, emit);
      } else {
        await _onSwipeItemUpdate(event, emit);
      }
    } catch (e) {
      emit(CategoryProductsError('Nem sikerült frissíteni a terméket: $e'));
    }
  }

  Future<void> _onCreateMultipleItems(
    UpdateItemListType event,
    Emitter<CategoryProductsState> emit,
  ) async {
    if (state is! CategoryProductsLoaded) {
      emit(const CategoryProductsLoading());
      return;
    }

    final currentState = state as CategoryProductsLoaded;

    try {
      final newItemIds = await listItemRepository.createMultipleItems(
        event.itemId,
        event.profileId,
      );

      if (newItemIds.isEmpty) {
        final originalItem = await listItemRepository.getItemById(event.itemId);
        if (originalItem != null && originalItem.db >= 25) {
          emit(const CategoryProductsError(
              'Nem lehet több darabot létrehozni, ha a mennyiség 25 vagy több. Kérlek használd a kettévágást.'));
        } else {
          emit(const CategoryProductsError(
              'Nem sikerült több darabot létrehozni'));
        }
        return;
      }

      final updatedState = await _updateStateWithNewItems(
        currentState,
        event.itemId,
        newItemIds,
      );

      emit(updatedState.copyWith(hasContextMenuAction: true));
    } catch (e) {
      emit(CategoryProductsError('Nem sikerült több terméket létrehozni: $e'));
    }
  }

  Future<void> _onDuplicateItem(
    UpdateItemListType event,
    Emitter<CategoryProductsState> emit,
  ) async {
    await _handleSliceDuplicateOrTakeOne(event, emit, isDuplicate: true);
  }

  Future<void> _onSliceItem(
    UpdateItemListType event,
    Emitter<CategoryProductsState> emit,
  ) async {
    await _handleSliceDuplicateOrTakeOne(event, emit, isSlice: true);
  }

  Future<void> _onTakeOneItem(
    UpdateItemListType event,
    Emitter<CategoryProductsState> emit,
  ) async {
    await _handleSliceDuplicateOrTakeOne(event, emit, isTakeOne: true);
  }

  Future<void> _handleSliceDuplicateOrTakeOne(
    UpdateItemListType event,
    Emitter<CategoryProductsState> emit, {
    bool isDuplicate = false,
    bool isSlice = false,
    bool isTakeOne = false,
  }) async {
    if (state is! CategoryProductsLoaded) {
      emit(const CategoryProductsLoading());
      return;
    }

    final currentState = state as CategoryProductsLoaded;

    final newItemId = await listItemRepository.sliceItem(
      event.itemId,
      event.profileId,
      isDuplicate: isDuplicate,
      isTakeOne: isTakeOne,
    );

    if (newItemId != null) {
      final updatedState = await _updateStateWithNewItems(
        currentState,
        event.itemId,
        [newItemId],
      );

      emit(updatedState.copyWith(hasContextMenuAction: true));
    }
  }

  Future<void> _onSwipeItemUpdate(
    UpdateItemListType event,
    Emitter<CategoryProductsState> emit,
  ) async {
    await listItemRepository.updateItemListType(
      event.itemId,
      event.newListType,
      event.profileId,
    );

    if (state is CategoryProductsLoaded) {
      final currentState = state as CategoryProductsLoaded;
      final updatedSwipedItems = Set<String>.from(currentState.swipedItems);
      updatedSwipedItems.add(event.itemId);

      final updatedProductItems =
          Map<String, ProductModel>.from(currentState.productItems);
      updatedProductItems.remove(event.itemId);

      final updatedOrderedIds =
          List<String>.from(currentState.orderedProductIds);
      updatedOrderedIds.remove(event.itemId);

      emit(currentState.copyWith(
        swipedItems: updatedSwipedItems,
        productItems: updatedProductItems,
        orderedProductIds: updatedOrderedIds,
      ));
    }
  }

  Future<CategoryProductsLoaded> _updateStateWithNewItems(
    CategoryProductsLoaded currentState,
    String originalItemId,
    List<String> newItemIds,
  ) async {
    final updatedProductItems =
        Map<String, ProductModel>.from(currentState.productItems);
    final updatedOrderedIds = List<String>.from(currentState.orderedProductIds);
    final updatedProductIdToProfileId =
        Map<String, String>.from(currentState.productIdToProfileId);

    final updatedOriginalItem =
        await listItemRepository.getItemById(originalItemId);
    if (updatedOriginalItem != null) {
      updatedProductItems[originalItemId] =
          listItemRepository.mapToProductModel(updatedOriginalItem);
      updatedProductIdToProfileId[originalItemId] =
          updatedOriginalItem.profileId;
    }

    final originalIndex = updatedOrderedIds.indexOf(originalItemId);
    int insertIndex =
        originalIndex != -1 ? originalIndex + 1 : updatedOrderedIds.length;

    for (final newItemId in newItemIds) {
      final newItem = await listItemRepository.getItemById(newItemId);
      if (newItem != null) {
        final newProduct = listItemRepository.mapToProductModel(newItem);
        updatedProductItems[newItemId] = newProduct;
        updatedProductIdToProfileId[newItemId] = newItem.profileId;
        updatedOrderedIds.insert(insertIndex++, newItemId);
      }
    }

    return currentState.copyWith(
      productItems: updatedProductItems,
      orderedProductIds: updatedOrderedIds,
      productIdToProfileId: updatedProductIdToProfileId,
    );
  }

  void _onSwipeItem(
    SwipeItem event,
    Emitter<CategoryProductsState> emit,
  ) {
    if (state is! CategoryProductsLoaded) return;

    final currentState = state as CategoryProductsLoaded;

    final updatedSwipedItems = Set<String>.from(currentState.swipedItems);
    updatedSwipedItems.add(event.productId);

    final updatedState = currentState.copyWith(
      swipedItems: updatedSwipedItems,
    );

    emit(CategoryProductsItemSwiped(
      productId: event.productId,
      direction: event.direction,
      targetListType: event.targetListType,
      previousState: updatedState,
    ));
  }

  void _onProcessSwipedItems(
    ProcessSwipedItems event,
    Emitter<CategoryProductsState> emit,
  ) {
    if (state is! CategoryProductsLoaded) return;

    final currentState = state as CategoryProductsLoaded;
    if (currentState.swipedItems.isEmpty) return;

    final swipedItemsCopy = Set<String>.from(currentState.swipedItems);
    final Map<String, ProductModel> updatedProductItems =
        Map.from(currentState.productItems);
    final List<String> updatedOrderedIds =
        List.from(currentState.orderedProductIds);

    for (final productId in swipedItemsCopy) {
      final index = updatedOrderedIds.indexOf(productId);
      if (index != -1) {
        updatedOrderedIds.removeAt(index);
        updatedProductItems.remove(productId);
      }
    }

    emit(currentState.copyWith(
      swipedItems: {},
      productItems: updatedProductItems,
      orderedProductIds: updatedOrderedIds,
    ));
  }

  void _onInitializeProducts(
    InitializeProducts event,
    Emitter<CategoryProductsState> emit,
  ) {
    if (state is! CategoryProductsLoaded) return;

    final currentState = state as CategoryProductsLoaded;

    final result = ProductProcessingHelper.buildProductItemsMap(
      event.products,
      event.productIds,
    );

    emit(currentState.copyWith(
      products: event.products,
      productIds: event.productIds,
      productItems: result.productItems,
      orderedProductIds: result.orderedProductIds,
      isInitialized: true,
    ));
  }

  void _onAddItem(
    AddItem event,
    Emitter<CategoryProductsState> emit,
  ) {
    if (state is! CategoryProductsLoaded) return;

    final currentState = state as CategoryProductsLoaded;

    final updatedProductItems =
        Map<String, ProductModel>.from(currentState.productItems);
    updatedProductItems[event.productId] = event.product;

    final updatedOrderedIds = List<String>.from(currentState.orderedProductIds);
    updatedOrderedIds.add(event.productId);

    emit(currentState.copyWith(
      productItems: updatedProductItems,
      orderedProductIds: updatedOrderedIds,
    ));
  }

  void _onRemoveItem(
    RemoveItem event,
    Emitter<CategoryProductsState> emit,
  ) {
    if (state is! CategoryProductsLoaded) return;

    final currentState = state as CategoryProductsLoaded;

    if (currentState.swipedItems.contains(event.productId)) return;

    final index = currentState.orderedProductIds.indexOf(event.productId);
    if (index == -1) return;

    final updatedOrderedIds = List<String>.from(currentState.orderedProductIds);
    updatedOrderedIds.removeAt(index);

    final updatedProductItems =
        Map<String, ProductModel>.from(currentState.productItems);
    updatedProductItems.remove(event.productId);

    emit(currentState.copyWith(
      productItems: updatedProductItems,
      orderedProductIds: updatedOrderedIds,
    ));
  }

  @override
  Future<void> close() {
    _itemsSubscription?.cancel();
    return super.close();
  }
}
