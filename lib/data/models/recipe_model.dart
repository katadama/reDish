import 'package:equatable/equatable.dart';

class RecipeModel extends Equatable {
  final String recipeName;
  final String description;
  final String cuisine;
  final String preparationTimeCategory;
  final int preparationTimeMinutes;
  final int servings;
  final String difficulty;
  final String mealType;
  final List<RecipeIngredient> ingredients;
  final Map<String, String> instructions;
  final String? error;

  const RecipeModel({
    required this.recipeName,
    required this.description,
    required this.cuisine,
    required this.preparationTimeCategory,
    required this.preparationTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.mealType,
    required this.ingredients,
    required this.instructions,
    this.error,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
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
        error: json['error'] as String,
      );
    }

    final List<RecipeIngredient> ingredients = [];
    if (json.containsKey('ingredients') && json['ingredients'] is List) {
      for (final ingredientJson in json['ingredients'] as List) {
        if (ingredientJson is Map<String, dynamic>) {
          ingredients.add(RecipeIngredient.fromJson(ingredientJson));
        }
      }
    }

    final Map<String, String> instructions = {};
    if (json.containsKey('instructions') && json['instructions'] is Map) {
      final instructionsJson = json['instructions'] as Map;
      instructionsJson.forEach((key, value) {
        instructions[key.toString()] = value.toString();
      });
    }

    return RecipeModel(
      recipeName: json['recipe_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cuisine: json['cuisine'] as String? ?? '',
      preparationTimeCategory:
          json['preparation_time_category'] as String? ?? '',
      preparationTimeMinutes:
          (json['preparation_time_minutes'] as num?)?.toInt() ?? 0,
      servings: (json['servings'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? '',
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  Map<String, dynamic> toJson() {
    if (error != null) {
      return {'error': error};
    }

    return {
      'recipe_name': recipeName,
      'description': description,
      'cuisine': cuisine,
      'preparation_time_category': preparationTimeCategory,
      'preparation_time_minutes': preparationTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'meal_type': mealType,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
    };
  }

  @override
  List<Object?> get props => [
        recipeName,
        description,
        cuisine,
        preparationTimeCategory,
        preparationTimeMinutes,
        servings,
        difficulty,
        mealType,
        ingredients,
        instructions,
        error,
      ];
}

class RecipeIngredient extends Equatable {
  final String name;
  final String amount;

  const RecipeIngredient({
    required this.name,
    required this.amount,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }

  @override
  List<Object> get props => [name, amount];
}
