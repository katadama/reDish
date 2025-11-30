import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:coo_list/utils/list_type_constants.dart';
import 'package:coo_list/logic/category_products/category_products_bloc.dart';
import 'package:coo_list/logic/category_products/category_products_event.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/utils/category_messages.dart';
import 'package:coo_list/utils/profile_validator.dart';

class CategorySwipeHandler {
  CategorySwipeHandler._();

  static void handleItemSwipe(
    BuildContext context,
    String productId,
    int targetListType,
    String categoryId,
    int currentListType,
  ) {
    if (productId.isEmpty) {
      _showErrorSnackBar(context, CategoryMessages.invalidProductId);
      return;
    }

    final profileBloc = context.read<ProfileBloc>();
    final profileError = ProfileValidator.validateProfile(profileBloc);

    if (profileError != null) {
      _showErrorSnackBar(context, profileError);
      return;
    }

    final profileId = ProfileValidator.getProfileId(profileBloc);
    if (profileId == null) {
      _showErrorSnackBar(context, CategoryMessages.invalidProfileId);
      return;
    }

    context.read<CategoryProductsBloc>().add(
          UpdateItemListType(
            itemId: productId,
            newListType: targetListType,
            categoryId: categoryId,
            currentListType: currentListType,
            profileId: profileId,
          ),
        );

    _showSuccessSnackBar(context, targetListType);
  }

  static int getTargetListType(
    SwipeDirection direction,
    int currentListType,
  ) {
    if (direction == SwipeDirection.startToEnd) {
      return currentListType == ListType.shopping
          ? ListType.home
          : ListType.shopping;
    } else {
      return ListType.bin;
    }
  }

  static String getSuccessMessage(int targetListType) {
    if (targetListType == ListType.shopping) {
      return CategoryMessages.movedToShopping;
    } else if (targetListType == ListType.home) {
      return CategoryMessages.movedToHome;
    } else {
      return CategoryMessages.movedToBin;
    }
  }

  static void _showSuccessSnackBar(BuildContext context, int targetListType) {
    final message = getSuccessMessage(targetListType);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            targetListType == ListType.bin ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
