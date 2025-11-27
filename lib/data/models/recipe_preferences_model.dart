import 'package:equatable/equatable.dart';

class RecipePreferencesModel extends Equatable {
  final String cuisine;
  final String preparationTime;
  final int servings;
  final String difficulty;
  final String mealType;
  final String generationType;

  const RecipePreferencesModel({
    this.cuisine = 'Magyar',
    this.preparationTime = 'Átlagos',
    this.servings = 3,
    this.difficulty = 'Közepes',
    this.mealType = 'Ebéd',
    this.generationType = 'Lejárattal',
  });

  RecipePreferencesModel copyWith({
    String? cuisine,
    String? preparationTime,
    int? servings,
    String? difficulty,
    String? mealType,
    String? generationType,
  }) {
    return RecipePreferencesModel(
      cuisine: cuisine ?? this.cuisine,
      preparationTime: preparationTime ?? this.preparationTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      mealType: mealType ?? this.mealType,
      generationType: generationType ?? this.generationType,
    );
  }

  @override
  List<Object> get props => [
        cuisine,
        preparationTime,
        servings,
        difficulty,
        mealType,
        generationType,
      ];
}
