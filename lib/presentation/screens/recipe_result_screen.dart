import 'package:flutter/material.dart';
import 'package:coo_list/data/models/recipe_model.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_header.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_ingredients_tab.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_preparation_tab.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_tabs_view.dart';

class RecipeResultScreen extends StatefulWidget {
  static const String routeName = '/recipe-result';
  final RecipeModel recipe;

  const RecipeResultScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeResultScreen> createState() => _RecipeResultScreenState();
}

class _RecipeResultScreenState extends State<RecipeResultScreen> {
  late Map<String, bool> _checkedIngredients;

  @override
  void initState() {
    super.initState();
    _checkedIngredients = {};
    for (var ingredient in widget.recipe.ingredients) {
      _checkedIngredients[ingredient.name] = false;
    }
  }

  void _handleCheckedIngredientsChanged(Map<String, bool> checkedIngredients) {
    setState(() {
      _checkedIngredients = checkedIngredients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          Navigator.of(context).pop({'refresh': true});
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Recept',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF000000),
            ),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 18,
            ),
            onPressed: () {
              Navigator.of(context).pop({'refresh': true});
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              RecipeHeader(recipe: widget.recipe),

              Expanded(
                child: RecipeTabsView(
                  tabs: const ['Hozzávalók', 'Elkészítés'],
                  children: [
                    RecipeIngredientsTab(
                      recipe: widget.recipe,
                      initialCheckedIngredients: _checkedIngredients,
                      onCheckedIngredientsChanged:
                          _handleCheckedIngredientsChanged,
                    ),
                    RecipePreparationTab(recipe: widget.recipe),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
