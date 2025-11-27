import 'package:flutter/material.dart';
import 'package:coo_list/config/list_type_constants.dart';
import 'package:coo_list/presentation/screens/category_grid_screen.dart';

class HomeListScreen extends StatelessWidget {
  static const String routeName = '/home-list';

  const HomeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryGridScreen(
      config: CategoryGridConfig(
        listType: ListType.home,
        emptyStateMessage:
            'Nem található otthoni termék. Adj hozzá termékeket az otthoni készletedhez!',
        initialStateMessage: 'Válassz ki egy kategóriát az otthoni termékek megtekintéséhez',
      ),
    );
  }
}
