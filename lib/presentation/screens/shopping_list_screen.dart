import 'package:flutter/material.dart';
import 'package:coo_list/config/list_type_constants.dart';
import 'package:coo_list/presentation/screens/category_grid_screen.dart';

class ShoppingListScreen extends StatelessWidget {
  static const String routeName = '/shopping-list';

  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryGridScreen(
      config: CategoryGridConfig(
        listType: ListType.shopping,
        emptyStateMessage:
            'Nem található bevásárló termék. Adj hozzá termékeket a bevásárló listádhoz!',
        initialStateMessage: 'Válassz ki egy kategóriát a termékek megtekintéséhez',
      ),
    );
  }
}
