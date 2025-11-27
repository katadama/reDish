import 'package:equatable/equatable.dart';
import 'package:coo_list/data/models/product_model.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeInventory extends RecipeEvent {
  const LoadHomeInventory();
}

class GenerateRecipe extends RecipeEvent {
  final List<ProductModel> selectedIngredients;
  final String cuisine;
  final String preparationTime;
  final int servings;
  final String difficulty;
  final String mealType;

  const GenerateRecipe({
    required this.selectedIngredients,
    required this.cuisine,
    required this.preparationTime,
    required this.servings,
    required this.difficulty,
    required this.mealType,
  });

  @override
  List<Object?> get props => [
        selectedIngredients,
        cuisine,
        preparationTime,
        servings,
        difficulty,
        mealType,
      ];
}

class GenerateRecipeWithSpoilage extends RecipeEvent {
  final List<ProductModel> selectedIngredients;
  final String cuisine;
  final String preparationTime;
  final int servings;
  final String difficulty;
  final String mealType;

  const GenerateRecipeWithSpoilage({
    required this.selectedIngredients,
    required this.cuisine,
    required this.preparationTime,
    required this.servings,
    required this.difficulty,
    required this.mealType,
  });

  @override
  List<Object?> get props => [
        selectedIngredients,
        cuisine,
        preparationTime,
        servings,
        difficulty,
        mealType,
      ];
}

class ResetRecipeState extends RecipeEvent {
  const ResetRecipeState();
}

class UpdateCheckedIngredients extends RecipeEvent {
  final Map<String, bool> checkedIngredients;

  const UpdateCheckedIngredients(this.checkedIngredients);

  @override
  List<Object?> get props => [checkedIngredients];
}
