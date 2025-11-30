import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/utils/list_type_constants.dart';
import 'package:coo_list/logic/bin/bin_bloc.dart';
import 'package:coo_list/logic/bin/bin_event.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/logic/profile/profile_state.dart';

class BinSwipeHandler {
  static void handleItemSwipe(
    BuildContext context,
    String productId,
    int targetListType,
  ) {
    if (productId.isEmpty) {
      _showErrorSnackBar(context, 'Hiba: Érvénytelen termék ID');
      return;
    }

    final profileState = context.read<ProfileBloc>().state;
    String profileId = '';

    if (profileState is ProfileSelected) {
      profileId = profileState.profile.id;

      if (profileId.isEmpty) {
        _showErrorSnackBar(context, 'Hiba: Érvénytelen profil ID');
        return;
      }

      context.read<BinBloc>().add(
            UpdateBinItemListType(
              itemId: productId,
              newListType: targetListType,
              profileId: profileId,
            ),
          );

      _showSuccessSnackBar(context, targetListType);
    } else {
      _showErrorSnackBar(context, 'Hiba: Nincs kiválasztott profil');
    }
  }

  static int getTargetListType(bool isRightSwipe) {
    if (isRightSwipe) {
      return ListType.home;
    } else {
      return ListType.shopping;
    }
  }

  static String getSuccessMessage(int targetListType) {
    if (targetListType == ListType.shopping) {
      return 'Áthelyezve a bevásárló listába';
    } else if (targetListType == ListType.home) {
      return 'Áthelyezve az otthoni listába';
    } else {
      return 'Áthelyezve a kukába';
    }
  }

  static void _showSuccessSnackBar(BuildContext context, int targetListType) {
    final message = getSuccessMessage(targetListType);
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
}
