import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/data/models/recipe_model.dart';
import 'package:coo_list/services/openrouter_service.dart';

class RecipeRepository {
  final OpenRouterService _openRouterService;

  RecipeRepository({required OpenRouterService openRouterService})
      : _openRouterService = openRouterService;

  Future<RecipeModel> generateRecipe({
    required List<ProductModel> ingredients,
    required String cuisine,
    required String preparationTime,
    required int servings,
    required String difficulty,
    required String mealType,
  }) async {
    try {
      final List<Map<String, dynamic>> ingredientMaps = ingredients
          .map((product) => {
                'name': product.name,
                'weight': product.weight,
                'db': product.db,
                'spoilage': product.getDaysUntilSpoiled() ?? product.spoilage,
              })
          .toList();

      final recipeJson = await _openRouterService.generateRecipeDynamic(
        ingredientMaps,
        cuisine,
        preparationTime,
        servings,
        difficulty,
        mealType,
      );

      return RecipeModel.fromJson(recipeJson);
    } catch (e) {
      return RecipeModel(
        recipeName: '',
        description: '',
        cuisine: '',
        preparationTimeCategory: '',
        preparationTimeMinutes: 0,
        servings: 0,
        difficulty: '',
        mealType: '',
        ingredients: const [],
        instructions: const {},
        error: 'Nem sikerült a recept generálása: $e',
      );
    }
  }

  Future<RecipeModel> generateRecipeWithSpoilage({
    required List<ProductModel> ingredients,
    required String cuisine,
    required String preparationTime,
    required int servings,
    required String difficulty,
    required String mealType,
  }) async {
    try {
      final List<Map<String, dynamic>> ingredientMaps = ingredients
          .map((product) => {
                'name': product.name,
                'weight': product.weight,
                'db': product.db,
                'spoilage': product.getDaysUntilSpoiled() ?? product.spoilage,
              })
          .toList();

      final recipeJson =
          await _openRouterService.generateRecipeWithSpoilageDynamic(
        ingredientMaps,
        cuisine,
        preparationTime,
        servings,
        difficulty,
        mealType,
      );

      return RecipeModel.fromJson(recipeJson);
    } catch (e) {
      return RecipeModel(
        recipeName: '',
        description: '',
        cuisine: '',
        preparationTimeCategory: '',
        preparationTimeMinutes: 0,
        servings: 0,
        difficulty: '',
        mealType: '',
        ingredients: const [],
        instructions: const {},
        error:
            'Nem sikerült a recept generálása a lejárás előnyben részesítésével: $e',
      );
    }
  }
}
