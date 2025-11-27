import 'package:flutter/material.dart';
import 'package:coo_list/data/models/recipe_model.dart';
import 'package:coo_list/logic/recipe/recipe_bloc.dart';
import 'package:coo_list/logic/recipe/recipe_event.dart';
import 'package:coo_list/logic/recipe/recipe_state.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_header.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_ingredients_tab.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_preparation_tab.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_tabs_view.dart';

class RecipeResultContent extends StatefulWidget {
  final RecipeModel recipe;
  final RecipeBloc recipeBloc;

  const RecipeResultContent({
    super.key,
    required this.recipe,
    required this.recipeBloc,
  });

  @override
  State<RecipeResultContent> createState() => _RecipeResultContentState();
}

class _RecipeResultContentState extends State<RecipeResultContent> {
  late Map<String, bool> _checkedIngredients;

  @override
  void initState() {
    super.initState();
    _initializeCheckedIngredients();
  }

  void _initializeCheckedIngredients() {
    final state = widget.recipeBloc.state;

    if (state is RecipeGenerated) {
      _checkedIngredients = Map<String, bool>.from(state.checkedIngredients);
    } else if (state is RecipeGeneratedWithInventory) {
      _checkedIngredients = Map<String, bool>.from(state.checkedIngredients);
    } else {
      _checkedIngredients = {};
    }

    for (var ingredient in widget.recipe.ingredients) {
      if (!_checkedIngredients.containsKey(ingredient.name)) {
        _checkedIngredients[ingredient.name] = false;
      }
    }
  }

  void _handleCheckedIngredientsChanged(Map<String, bool> checkedIngredients) {
    setState(() {
      _checkedIngredients = checkedIngredients;
    });

    widget.recipeBloc.add(UpdateCheckedIngredients(checkedIngredients));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RecipeHeader(recipe: widget.recipe),

        Expanded(
          child: RecipeTabsView(
            tabs: const ['Hozzávalók', 'Elkészítés'],
            children: [
              RecipeIngredientsTab(
                recipe: widget.recipe,
                initialCheckedIngredients: _checkedIngredients,
                onCheckedIngredientsChanged: _handleCheckedIngredientsChanged,
              ),
              RecipePreparationTab(recipe: widget.recipe),
            ],
          ),
        ),
      ],
    );
  }
}
