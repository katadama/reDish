import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:coo_list/utils/list_type_constants.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/presentation/widgets/custom_context_menu.dart';
import 'package:coo_list/presentation/widgets/product_list_item.dart';
import 'package:coo_list/presentation/widgets/category/category_swipe_handler.dart';
import 'package:coo_list/presentation/widgets/category/category_context_menu_handler.dart';
import 'package:coo_list/logic/category_products/category_products_bloc.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/data/repositories/list_item_repository.dart';

class CategoryProductListItem extends StatelessWidget {
  final ProductModel product;
  final String productId;
  final int listType;
  final String categoryId;
  final VoidCallback onTap;
  final VoidCallback
      onSwipeStarted;
  final bool isSwiped;

  const CategoryProductListItem({
    super.key,
    required this.product,
    required this.productId,
    required this.listType,
    required this.categoryId,
    required this.onTap,
    required this.onSwipeStarted,
    this.isSwiped = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSwiped) {
      return const SizedBox.shrink();
    }

    final leftColor = listType == ListType.shopping
        ? Colors.blue.shade300
        : Colors.green.shade300;
    final rightColor = Colors.red.shade300;

    return SwipeableTile.card(
      color: Colors.transparent,
      shadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 4,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
      horizontalPadding: 0,
      verticalPadding: 0,
      key: ValueKey('swipeable_$productId'),

      direction: SwipeDirection.horizontal,
      swipeThreshold: 0.4,

      onSwiped: (direction) {
        final targetListType = CategorySwipeHandler.getTargetListType(
          direction,
          listType,
        );

        onSwipeStarted();

        CategorySwipeHandler.handleItemSwipe(
          context,
          productId,
          targetListType,
          categoryId,
          listType,
        );
      },

      backgroundBuilder: (context, direction, progress) {
        final isLeftSwipe = direction == SwipeDirection.startToEnd;
        final color = isLeftSwipe ? leftColor : rightColor;
        final alignment =
            isLeftSwipe ? Alignment.centerLeft : Alignment.centerRight;
        final padding = isLeftSwipe
            ? const EdgeInsets.only(left: 20.0)
            : const EdgeInsets.only(right: 20.0);
        final icon = isLeftSwipe
            ? (listType == ListType.shopping
                ? Icons.home_outlined
                : Icons.shopping_bag_outlined)
            : Icons.delete_outline;

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
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: CustomContextMenu(
            menuBackgroundColor: Colors.white,
            menuBorderRadius: 12.0,
            menuElevation: 8.0,
            animationDuration: const Duration(milliseconds: 200),
            useBlurEffect: true,
            blurSigma: 15.0,
            menuItems: [
              CustomContextMenuItem(
                title: 'Duplikálás',
                icon: Icons.content_copy,
                onTap: () {
                  _handleDuplicateItem(context);
                },
              ),
              CustomContextMenuItem(
                title: 'Kettévágás',
                icon: Icons.content_cut,
                onTap: () {
                  _handleSliceItem(context);
                },
              ),
              CustomContextMenuItem(
                title: 'Egy darabot kivenni',
                icon: Icons.filter_1,
                onTap: () {
                  _handleTakeOneItem(context);
                },
              ),
              CustomContextMenuItem(
                title: 'Darabolás',
                icon: Icons.copy_all,
                onTap: () {
                  _handleCreateMultipleItems(context);
                },
              ),
            ],
            child: ProductListItem(
              product: product,
              listType: listType,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  void _handleDuplicateItem(BuildContext context) {
    final bloc = context.read<CategoryProductsBloc>();
    final profileBloc = context.read<ProfileBloc>();
    CategoryContextMenuHandler.handleDuplicateItem(
      context,
      productId,
      categoryId,
      listType,
      bloc,
      profileBloc,
    );
  }

  void _handleSliceItem(BuildContext context) {
    final bloc = context.read<CategoryProductsBloc>();
    final profileBloc = context.read<ProfileBloc>();
    CategoryContextMenuHandler.handleSliceItem(
      context,
      productId,
      categoryId,
      listType,
      bloc,
      profileBloc,
    );
  }

  void _handleTakeOneItem(BuildContext context) {
    final bloc = context.read<CategoryProductsBloc>();
    final profileBloc = context.read<ProfileBloc>();
    CategoryContextMenuHandler.handleTakeOneItem(
      context,
      productId,
      categoryId,
      listType,
      bloc,
      profileBloc,
    );
  }

  void _handleCreateMultipleItems(BuildContext context) {
    final bloc = context.read<CategoryProductsBloc>();
    final profileBloc = context.read<ProfileBloc>();
    final listItemRepository = context.read<ListItemRepository>();
    CategoryContextMenuHandler.handleCreateMultipleItems(
      context,
      productId,
      categoryId,
      listType,
      bloc,
      profileBloc,
      listItemRepository,
    );
  }
}
