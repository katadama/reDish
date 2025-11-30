import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/config/app_router.dart';
import 'package:coo_list/utils/list_type_constants.dart';
import 'package:coo_list/presentation/widgets/custom_context_menu.dart';
import 'package:coo_list/data/models/category_model.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/data/repositories/list_item_repository.dart';
import 'package:coo_list/logic/category_products/category_products_bloc.dart';
import 'package:coo_list/logic/category_products/category_products_event.dart';
import 'package:coo_list/logic/category_products/category_products_state.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/logic/profile/profile_event.dart';
import 'package:coo_list/logic/profile/profile_state.dart';
import 'package:coo_list/presentation/widgets/category/category_product_list_item.dart';

class CategoryDetailScreen extends StatefulWidget {
  final CategoryModel category;
  final int listType;
  final bool showAppBar;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    this.listType = ListType.shopping,
    this.showAppBar = true,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late CategoryProductsBloc _categoryProductsBloc;

  @override
  void initState() {
    super.initState();
    _categoryProductsBloc = CategoryProductsBloc(
      listItemRepository: RepositoryProvider.of<ListItemRepository>(context),
    )..add(LoadCategoryProducts(widget.category.id, listType: widget.listType));
  }

  @override
  void dispose() {
    _categoryProductsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider.value(
      value: _categoryProductsBloc,
      child: _CategoryProductsList(
        listType: widget.listType,
        categoryId: widget.category.id,
      ),
    );

    if (!widget.showAppBar) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Text(
            '<',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop({'refresh': true});
          },
        ),
      ),
      body: content,
    );
  }
}

class _CategoryProductsList extends StatefulWidget {
  final int listType;
  final String categoryId;

  const _CategoryProductsList({
    required this.listType,
    required this.categoryId,
  });

  @override
  State<_CategoryProductsList> createState() => _CategoryProductsListState();
}

class _CategoryProductsListState extends State<_CategoryProductsList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final Map<String, ProductModel> _productItems = {};
  final List<String> _orderedProductIds = [];
  final Map<String, DateTime> _swipedItems = {};
  final Map<String, String> _productIdToProfileId = {};
  bool _isInitialized = false;
  String? _currentProfileId;

  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const Duration _swipedItemExpiry = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
  }

  void _updateCurrentProfileId() {
    final profileBloc = context.read<ProfileBloc>();
    final profileState = profileBloc.state;
    if (profileState is ProfileSelected) {
      _currentProfileId = profileState.profile.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateCurrentProfileId();

    return BlocConsumer<CategoryProductsBloc, CategoryProductsState>(
      listener: (context, state) {
        if (state is CategoryProductsLoaded) {
          if (state.hasContextMenuAction) {
            _handleContextMenuActionUpdate(state);
          } else {
            _handleProductListChanges(
                state.products, state.productIds, state.productIdToProfileId);
          }
        }
      },
      builder: (context, state) {
        if (state is CategoryProductsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF34744),
            ),
          );
        }

        if (state is CategoryProductsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (state.message.contains(
                      'Nem lehet több terméket létrehozni 25 vagy több mennyiség esetén'))
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Vissza'),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        if (state is CategoryProductsLoaded) {
          final products = state.products;

          if (products.isEmpty) {
            return Center(
              child: Text(
                widget.listType == ListType.shopping
                    ? 'Nincs bevásárló termék ebben a kategóriában'
                    : 'Nincs otthoni termék ebben a kategóriában',
              ),
            );
          }

          return AnimatedList(
            key: _listKey,
            initialItemCount: _orderedProductIds.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index, animation) {
              if (index >= _orderedProductIds.length) {
                return const SizedBox.shrink();
              }

              final productId = _orderedProductIds[index];
              final product = _productItems[productId];

              if (product == null) {
                return const SizedBox.shrink();
              }

              if (_isItemSwiped(productId)) {
                return const SizedBox.shrink();
              }

              return KeyedSubtree(
                key: ValueKey('product_$productId'),
                child:
                    _buildAnimatedItem(context, product, productId, animation),
              );
            },
          );
        }

        return const Center(
          child: Text('Nincs elérhető termék'),
        );
      },
    );
  }

  Widget _buildAnimatedItem(
    BuildContext context,
    ProductModel product,
    String productId,
    Animation<double> animation, {
    bool isRemoving = false,
  }) {
    Offset beginOffset = const Offset(0, -0.5);
    Offset endOffset = Offset.zero;

    if (isRemoving) {
      beginOffset = Offset.zero;
      endOffset = const Offset(0, 0.5);
    }

    return SlideTransition(
      position: animation.drive(Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      )),
      child: FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: 0.0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: CategoryProductListItem(
              product: product,
              productId: productId,
              listType: widget.listType,
              categoryId: widget.categoryId,
              onTap: () =>
                  _navigateToProductDetails(context, product, productId),
              onSwipeStarted: () {
                setState(() {
                  _swipedItems[productId] = DateTime.now();
                  _removeItemWithoutAnimation(productId);
                });
              },
              isSwiped: _isItemSwiped(productId),
            ),
          ),
        ),
      ),
    );
  }

  bool _isItemSwiped(String productId) {
    if (!_swipedItems.containsKey(productId)) {
      return false;
    }
    final swipeTime = _swipedItems[productId]!;
    final now = DateTime.now();
    if (now.difference(swipeTime) > _swipedItemExpiry) {
      _swipedItems.remove(productId);
      return false;
    }
    return true;
  }

  void _cleanupExpiredSwipedItems() {
    final now = DateTime.now();
    _swipedItems.removeWhere(
        (id, timestamp) => now.difference(timestamp) > _swipedItemExpiry);
  }

  void _handleProductListChanges(
      List<ProductModel> newProducts,
      Map<String, String> newProductIds,
      Map<String, String> productIdToProfileId) {
    if (!_isInitialized) {
      _initializeProducts(newProducts, newProductIds);
      return;
    }

    _cleanupExpiredSwipedItems();

    final Set<String> currentIds = Set.from(_orderedProductIds);
    final Map<String, ProductModel> newProductsMap = {};

    final List<String> newOrderedIds = [];

    for (int i = 0; i < newProducts.length; i++) {
      final String indexStr = i.toString();
      if (newProductIds.containsKey(indexStr)) {
        final String id = newProductIds[indexStr]!;
        newProductsMap[id] = newProducts[i];
        newOrderedIds.add(id);
      }
    }

    final Set<String> idsToRemove =
        currentIds.where((id) => !newProductsMap.containsKey(id)).toSet();

    final Set<String> idsToAdd = newProductsMap.keys
        .where((id) => !currentIds.contains(id) && !_isItemSwiped(id))
        .toSet();

    final Set<String> idsToUpdate = currentIds
        .where((id) => newProductsMap.containsKey(id) && !_isItemSwiped(id))
        .toSet();

    final List<MapEntry<String, ProductModel>> itemsToAdd = [];
    for (final id in idsToAdd) {
      if (newProductsMap.containsKey(id)) {
        itemsToAdd.add(MapEntry(id, newProductsMap[id]!));
      }
    }

    if (itemsToAdd.isEmpty) {
      setState(() {
        for (final id in idsToRemove) {
          if (_isItemSwiped(id)) {
            _removeItemWithoutAnimation(id);
            _swipedItems.remove(id);
          } else {
            final profileId =
                productIdToProfileId[id] ?? _productIdToProfileId[id];
            final shouldAnimate = profileId != null &&
                profileId != _currentProfileId &&
                _currentProfileId != null;

            if (shouldAnimate) {
              _removeItem(id);
            } else {
              _removeItemWithoutAnimation(id);
            }
            _productIdToProfileId.remove(id);
          }
        }

        for (final id in idsToUpdate) {
          _productItems[id] = newProductsMap[id]!;
          if (productIdToProfileId.containsKey(id)) {
            _productIdToProfileId[id] = productIdToProfileId[id]!;
          }
        }
      });
      return;
    }

    setState(() {
      for (final id in idsToRemove) {
        if (_isItemSwiped(id)) {
          _removeItemWithoutAnimation(id);
          _swipedItems.remove(id);
        } else {
          final profileId =
              productIdToProfileId[id] ?? _productIdToProfileId[id];
          final shouldAnimate = profileId != null &&
              profileId != _currentProfileId &&
              _currentProfileId != null;

          if (shouldAnimate) {
            _removeItem(id);
          } else {
            _removeItemWithoutAnimation(id);
          }
          _productIdToProfileId.remove(id);
        }
      }

      for (final id in idsToUpdate) {
        _productItems[id] = newProductsMap[id]!;
        if (productIdToProfileId.containsKey(id)) {
          _productIdToProfileId[id] = productIdToProfileId[id]!;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final List<({String id, ProductModel product, int insertIndex})>
          insertions = [];

      for (final entry in itemsToAdd) {
        final id = entry.key;
        final product = entry.value;

        if (_productItems.containsKey(id)) {
          continue;
        }

        final stateIndex = newOrderedIds.indexOf(id);
        int insertIndex;
        if (stateIndex == -1) {
          insertIndex = _orderedProductIds.length;
        } else {
          if (stateIndex > 0) {
            final previousItemId = newOrderedIds[stateIndex - 1];
            final previousIndex = _orderedProductIds.indexOf(previousItemId);
            insertIndex = previousIndex != -1
                ? previousIndex + 1
                : _orderedProductIds.length;
          } else {
            insertIndex = 0;
          }
        }

        insertions.add((id: id, product: product, insertIndex: insertIndex));
      }

      if (insertions.isNotEmpty) {
        insertions.sort((a, b) => b.insertIndex.compareTo(a.insertIndex));

        setState(() {
          for (final insertion in insertions) {
            _productItems[insertion.id] = insertion.product;
            _orderedProductIds.insert(insertion.insertIndex, insertion.id);

            if (productIdToProfileId.containsKey(insertion.id)) {
              _productIdToProfileId[insertion.id] =
                  productIdToProfileId[insertion.id]!;
            }

            if (_listKey.currentState != null) {
              _listKey.currentState!.insertItem(
                insertion.insertIndex,
                duration: _animationDuration,
              );
            }
          }
        });
      }
    });
  }

  void _initializeProducts(
      List<ProductModel> products, Map<String, String> productIds) {
    setState(() {
      _productItems.clear();
      _orderedProductIds.clear();

      final Map<String, ProductModel> productsById = {};
      final List<String> newIds = [];

      for (int i = 0; i < products.length; i++) {
        final String indexStr = i.toString();
        if (productIds.containsKey(indexStr)) {
          final String id = productIds[indexStr]!;
          productsById[id] = products[i];
          newIds.add(id);
        }
      }

      for (final id in newIds) {
        _productItems[id] = productsById[id]!;
        _orderedProductIds.add(id);
      }

      _isInitialized = true;
    });
  }

  void _removeItem(String productId) {
    final index = _orderedProductIds.indexOf(productId);
    if (index == -1) return;

    final product = _productItems[productId];
    if (product == null) return;

    final ProductModel productCopy = product;
    final int indexCopy = index;

    _orderedProductIds.removeAt(index);
    _productItems.remove(productId);

    if (_listKey.currentState != null) {
      _listKey.currentState!.removeItem(
        indexCopy,
        (context, animation) => _buildAnimatedItem(
          context,
          productCopy,
          productId,
          animation,
          isRemoving: true,
        ),
        duration: _animationDuration,
      );
    }
  }

  void _removeItemWithoutAnimation(String productId) {
    final index = _orderedProductIds.indexOf(productId);
    if (index == -1) return;

    final int indexCopy = index;

    _orderedProductIds.removeAt(index);
    _productItems.remove(productId);

    if (_listKey.currentState != null) {
      _listKey.currentState!.removeItem(
        indexCopy,
        (context, animation) => const SizedBox.shrink(),
        duration: Duration.zero,
      );
    }
  }

  void _navigateToProductDetails(
      BuildContext context, ProductModel product, String productId) async {
    CustomContextMenu.removeOverlay();

    final initialListType = widget.listType;
    final categoryId = widget.categoryId;
    final listType = widget.listType;
    final bloc = context.read<CategoryProductsBloc>();

    final result = await Navigator.of(context).pushNamed(
      AppRouter.productDetails,
      arguments: {
        'product': product,
        'productId': productId,
        'initialListType': initialListType,
      },
    );

    if (result is Map<String, dynamic> &&
        result['refresh'] == true &&
        mounted) {
      bloc.add(LoadCategoryProducts(categoryId, listType: listType));
    }
  }

  void _handleContextMenuActionUpdate(CategoryProductsLoaded state) {
    _cleanupExpiredSwipedItems();

    final Set<String> currentIds = Set.from(_orderedProductIds);
    final Set<String> newIds =
        state.productItems.keys.toSet().difference(currentIds);
    final Set<String> removedIds =
        currentIds.difference(state.productItems.keys.toSet());

    final List<MapEntry<String, ProductModel>> itemsToAdd = [];
    for (final id in newIds) {
      if (state.productItems.containsKey(id)) {
        itemsToAdd.add(MapEntry(id, state.productItems[id]!));
      }
    }

    if (itemsToAdd.isEmpty) {
      setState(() {
        for (final id
            in currentIds.intersection(state.productItems.keys.toSet())) {
          _productItems[id] = state.productItems[id]!;
        }

        for (final id in removedIds) {
          final index = _orderedProductIds.indexOf(id);
          if (index != -1) {
            _removeItemWithoutAnimation(id);
          }
        }
      });
      _updateProfileInfoSilently();
      return;
    }

    setState(() {
      for (final id
          in currentIds.intersection(state.productItems.keys.toSet())) {
        _productItems[id] = state.productItems[id]!;
      }

      for (final id in removedIds) {
        final index = _orderedProductIds.indexOf(id);
        if (index != -1) {
          _removeItemWithoutAnimation(id);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final List<({String id, ProductModel product, int insertIndex})>
          insertions = [];

      for (final entry in itemsToAdd) {
        final id = entry.key;
        final product = entry.value;

        if (_productItems.containsKey(id)) {
          continue;
        }

        final stateIndex = state.orderedProductIds.indexOf(id);
        int insertIndex;
        if (stateIndex == -1) {
          insertIndex = _orderedProductIds.length;
        } else {
          if (stateIndex > 0) {
            final previousItemId = state.orderedProductIds[stateIndex - 1];
            final previousIndex = _orderedProductIds.indexOf(previousItemId);
            insertIndex = previousIndex != -1
                ? previousIndex + 1
                : _orderedProductIds.length;
          } else {
            insertIndex = 0;
          }
        }

        insertions.add((id: id, product: product, insertIndex: insertIndex));
      }

      if (insertions.isNotEmpty) {
        insertions.sort((a, b) => b.insertIndex.compareTo(a.insertIndex));

        setState(() {
          for (final insertion in insertions) {
            _productItems[insertion.id] = insertion.product;
            _orderedProductIds.insert(insertion.insertIndex, insertion.id);

            if (_listKey.currentState != null) {
              _listKey.currentState!.insertItem(
                insertion.insertIndex,
                duration: _animationDuration,
              );
            }
          }
        });
      }
    });

    _updateProfileInfoSilently();
  }

  void _updateProfileInfoSilently() {
    final profileBloc = context.read<ProfileBloc>();
    final currentState = profileBloc.state;

    if (currentState is! ProfileSelected) {
      profileBloc.add(LoadProfiles(autoSelect: true));
    }
  }
}
