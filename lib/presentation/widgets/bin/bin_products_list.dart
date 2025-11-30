import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:coo_list/config/app_router.dart';
import 'package:coo_list/utils/list_type_constants.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/logic/bin/bin_bloc.dart';
import 'package:coo_list/logic/bin/bin_event.dart';
import 'package:coo_list/logic/bin/bin_state.dart';
import 'package:coo_list/presentation/widgets/bin/product_item.dart';
import 'package:coo_list/presentation/widgets/bin/bin_swipe_handler.dart';
import 'package:coo_list/presentation/widgets/product_list_item.dart';
import 'package:collection/collection.dart';

class BinProductsList extends StatefulWidget {
  const BinProductsList({super.key});

  @override
  State<BinProductsList> createState() => _BinProductsListState();
}

class _BinProductsListState extends State<BinProductsList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final Map<String, ProductItem> _productItems = {};
  final List<String> _orderedProductIds = [];
  final Set<String> _swipedItems = {};
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BinBloc, BinState>(
      listener: (context, state) {
        if (state is BinLoaded) {
          _handleProductListChanges(state.products, state.productIds);
        }
      },
      builder: (context, state) {
        if (state is BinLoading && !_isInitialized) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF34744),
            ),
          );
        }

        if (state is BinError && _orderedProductIds.isEmpty) {
          return Center(
            child: Text(
              'Hiba: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (_orderedProductIds.isEmpty) {
          return const Center(
            child: Text('Nincs termék a kukában'),
          );
        }

        return AnimatedList(
          key: _listKey,
          initialItemCount: _orderedProductIds.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemBuilder: (context, index, animation) {
            if (index >= _orderedProductIds.length) {
              return const SizedBox.shrink();
            }

            final productId = _orderedProductIds[index];
            final productItem = _productItems[productId];

            if (productItem == null) {
              return const SizedBox.shrink();
            }

            if (_swipedItems.contains(productId)) {
              return const SizedBox.shrink();
            }

            return _buildItem(context, productItem, animation);
          },
        );
      },
    );
  }

  void _handleProductListChanges(
      List<ProductModel> newProducts, Map<String, String> newProductIds) {
    if (!_isInitialized) {
      _initializeProducts(newProducts, newProductIds);
      return;
    }

    setState(() {
      final Set<String> currentIds = Set.from(_orderedProductIds);
      final Map<String, ProductModel> newProductsMap = {};

      newProductIds.forEach((indexStr, id) {
        final index = int.tryParse(indexStr);
        if (index != null && index < newProducts.length) {
          newProductsMap[id] = newProducts[index];
        }
      });

      final Set<String> idsToRemove = currentIds
          .where((id) =>
              !newProductsMap.containsKey(id) || _swipedItems.contains(id))
          .toSet();

      final Set<String> idsToAdd = newProductsMap.keys
          .where((id) => !currentIds.contains(id) && !_swipedItems.contains(id))
          .toSet();

      final Set<String> idsToUpdate = currentIds
          .where((id) =>
              newProductsMap.containsKey(id) && !_swipedItems.contains(id))
          .toSet();

      for (final id in idsToRemove) {
        if (_swipedItems.contains(id)) {
          _removeItemWithoutAnimation(id);
        } else {
          _removeItem(id);
        }
      }

      for (final id in idsToUpdate) {
        final existingItem = _productItems[id]!;
        final newProduct = newProductsMap[id]!;

        if (!const DeepCollectionEquality()
            .equals(existingItem.product, newProduct)) {
          existingItem.updateProduct(newProduct);
        }
      }

      for (final id in idsToAdd) {
        final newProduct = newProductsMap[id]!;
        _addItem(id, newProduct);
      }

      _swipedItems.clear();
    });
  }

  void _initializeProducts(
      List<ProductModel> products, Map<String, String> productIds) {
    setState(() {
      _productItems.clear();
      _orderedProductIds.clear();

      final List<String> newIds = [];
      final Map<String, ProductModel> productsById = {};

      productIds.forEach((indexStr, id) {
        final index = int.tryParse(indexStr);
        if (index != null && index < products.length) {
          newIds.add(id);
          productsById[id] = products[index];
        }
      });

      newIds.sort((a, b) {
        final DateTime? dateA = productsById[a]!.lastMovedAt;
        final DateTime? dateB = productsById[b]!.lastMovedAt;

        if (dateA == null && dateB == null) {
          return productsById[a]!.name.compareTo(productsById[b]!.name);
        } else if (dateA == null) {
          return 1;
        } else if (dateB == null) {
          return -1;
        }

        return dateB.compareTo(dateA);
      });

      for (final id in newIds) {
        _productItems[id] = ProductItem(id, productsById[id]!);
        _orderedProductIds.add(id);
      }

      _isInitialized = true;
    });
  }

  void _removeItem(String productId) {
    final index = _orderedProductIds.indexOf(productId);
    if (index == -1) return;

    final productItem = _productItems[productId];
    final int indexCopy = index;

    _orderedProductIds.removeAt(index);
    _productItems.remove(productId);
    _swipedItems.remove(productId);

    if (_listKey.currentState != null && productItem != null) {
      _listKey.currentState!.removeItem(
        indexCopy,
        (context, animation) => _buildItem(
          context,
          productItem,
          animation,
          isRemoving: true,
        ),
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _addItem(String productId, ProductModel product) {
    final newItem = ProductItem(productId, product);
    _productItems[productId] = newItem;

    _orderedProductIds.add(productId);

    if (_listKey.currentState != null) {
      _listKey.currentState!.insertItem(
        _orderedProductIds.length - 1,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _removeItemWithoutAnimation(String productId) {
    final index = _orderedProductIds.indexOf(productId);
    if (index == -1) return;

    final int indexCopy = index;

    _orderedProductIds.removeAt(index);
    _productItems.remove(productId);
    _swipedItems.remove(productId);

    if (_listKey.currentState != null) {
      _listKey.currentState!.removeItem(
        indexCopy,
        (context, animation) => const SizedBox.shrink(),
        duration: Duration.zero,
      );
    }
  }

  Widget _buildItem(BuildContext context, ProductItem productItem,
      Animation<double> animation,
      {bool isRemoving = false}) {
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
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
            child: _buildSwipeableTile(
                context, productItem.product, productItem.id),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeableTile(
      BuildContext context, ProductModel product, String productId) {
    if (_swipedItems.contains(productId)) {
      return const SizedBox.shrink();
    }

    final rightColor = Colors.blue.shade300;

    final leftColor = Colors.green.shade300;

    final Key tileKey =
        _productItems[productId]?.stableKey ?? ValueKey('swipeable_$productId');

    return SwipeableTile.card(
      color: Colors.transparent,
      shadow: const BoxShadow(color: Colors.transparent),
      horizontalPadding: 0,
      verticalPadding: 0,
      direction: SwipeDirection.horizontal,
      swipeThreshold: 0.4,
      onSwiped: (direction) {
        final isRightSwipe = direction == SwipeDirection.startToEnd;
        final targetListType = BinSwipeHandler.getTargetListType(isRightSwipe);

        setState(() {
          _swipedItems.add(productId);
        });

        _removeItemWithoutAnimation(productId);

        BinSwipeHandler.handleItemSwipe(context, productId, targetListType);
      },
      key: tileKey,
      backgroundBuilder: (context, direction, progress) {
        final isRightSwipe = direction == SwipeDirection.startToEnd;
        final color = isRightSwipe ? rightColor : leftColor;
        final alignment =
            isRightSwipe ? Alignment.centerLeft : Alignment.centerRight;
        final padding = isRightSwipe
            ? const EdgeInsets.only(left: 20.0)
            : const EdgeInsets.only(right: 20.0);
        final icon =
            isRightSwipe ? Icons.home_outlined : Icons.shopping_bag_outlined;

        return Container(
          color: color.withValues(alpha: 0.7),
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: padding,
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: const [],
          ),
          child: ProductListItem(
            product: product,
            listType: ListType.bin,
            onTap: () => _navigateToProductDetails(context, product, productId),
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetails(
      BuildContext context, ProductModel product, String productId) async {
    final binBloc = context.read<BinBloc>();

    final result = await Navigator.of(context).pushNamed(
      AppRouter.productDetails,
      arguments: {
        'product': product,
        'productId': productId,
        'initialListType': ListType.bin,
      },
    );

    if (result is Map<String, dynamic> &&
        result['refresh'] == true &&
        mounted) {
      binBloc.add(const LoadBinItems());
    }
  }
}
