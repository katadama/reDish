import 'package:flutter/material.dart';
import 'package:coo_list/data/repositories/list_item_repository.dart';
import 'package:coo_list/logic/category_products/category_products_bloc.dart';
import 'package:coo_list/logic/category_products/category_products_event.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/utils/category_messages.dart';
import 'package:coo_list/utils/profile_validator.dart';

class CategoryContextMenuHandler {
  CategoryContextMenuHandler._();

  static Future<void> handleDuplicateItem(
    BuildContext context,
    String productId,
    String categoryId,
    int listType,
    CategoryProductsBloc bloc,
    ProfileBloc profileBloc,
  ) async {
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

    try {
      _showLoadingSnackBar(context, CategoryMessages.duplicateInProgress);

      final event = UpdateItemListType(
        itemId: productId,
        newListType: listType,
        categoryId: categoryId,
        currentListType: listType,
        profileId: profileId,
        duplicate: true,
      );

      bloc.add(event);

      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;

      _showSuccessSnackBar(context, CategoryMessages.duplicateSuccess);
    } catch (e) {
      if (!context.mounted) return;

      _showErrorSnackBar(context, CategoryMessages.duplicateError(e.toString()));
    }
  }

  static Future<void> handleSliceItem(
    BuildContext context,
    String productId,
    String categoryId,
    int listType,
    CategoryProductsBloc bloc,
    ProfileBloc profileBloc,
  ) async {
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

    try {
      _showLoadingSnackBar(context, CategoryMessages.sliceInProgress);

      final event = UpdateItemListType(
        itemId: productId,
        newListType: listType,
        categoryId: categoryId,
        currentListType: listType,
        profileId: profileId,
        slice: true,
      );

      bloc.add(event);

      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;

      _showSuccessSnackBar(context, CategoryMessages.sliceSuccess);
    } catch (e) {
      if (!context.mounted) return;

      _showErrorSnackBar(context, CategoryMessages.sliceError(e.toString()));
    }
  }

  static Future<void> handleTakeOneItem(
    BuildContext context,
    String productId,
    String categoryId,
    int listType,
    CategoryProductsBloc bloc,
    ProfileBloc profileBloc,
  ) async {
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

    try {
      _showLoadingSnackBar(context, CategoryMessages.takeOneInProgress);

      final event = UpdateItemListType(
        itemId: productId,
        newListType: listType,
        categoryId: categoryId,
        currentListType: listType,
        profileId: profileId,
        takeOne: true,
      );

      bloc.add(event);

      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;

      _showSuccessSnackBar(context, CategoryMessages.takeOneSuccess);
    } catch (e) {
      if (!context.mounted) return;

      _showErrorSnackBar(context, CategoryMessages.takeOneError(e.toString()));
    }
  }

  static Future<void> handleCreateMultipleItems(
    BuildContext context,
    String productId,
    String categoryId,
    int listType,
    CategoryProductsBloc bloc,
    ProfileBloc profileBloc,
    ListItemRepository listItemRepository,
  ) async {
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

    try {
      final item = await listItemRepository.getItemById(productId);

      if (!context.mounted) return;

      if (item != null && item.db >= 25) {
        _showWarningSnackBar(context, CategoryMessages.createMultipleQuantityError);
        return;
      }

      _showLoadingSnackBar(context, CategoryMessages.createMultipleInProgress);

      final event = UpdateItemListType(
        itemId: productId,
        newListType: listType,
        categoryId: categoryId,
        currentListType: listType,
        profileId: profileId,
        duplicate: true,
        slice: true,
      );

      bloc.add(event);

      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;

      _showSuccessSnackBar(context, CategoryMessages.createMultipleSuccess);
    } catch (e) {
      if (!context.mounted) return;

      _showErrorSnackBar(
        context,
        CategoryMessages.createMultipleError(e.toString()),
      );
    }
  }

  static void _showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF424242),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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

  static void _showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.amber,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
