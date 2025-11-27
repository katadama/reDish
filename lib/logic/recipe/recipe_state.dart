import 'package:equatable/equatable.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/data/models/recipe_model.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];
}

class RecipeInitial extends RecipeState {
  const RecipeInitial();
}

class RecipeLoadingInventory extends RecipeState {
  const RecipeLoadingInventory();
}

class RecipeInventoryLoaded extends RecipeState {
  final List<ProductModel> availableIngredients;
  final List<ProductModel> selectedIngredients;

  const RecipeInventoryLoaded({
    required this.availableIngredients,
    this.selectedIngredients = const [],
  });

  @override
  List<Object?> get props => [availableIngredients, selectedIngredients];

  RecipeInventoryLoaded copyWith({
    List<ProductModel>? availableIngredients,
    List<ProductModel>? selectedIngredients,
  }) {
    return RecipeInventoryLoaded(
      availableIngredients: availableIngredients ?? this.availableIngredients,
      selectedIngredients: selectedIngredients ?? this.selectedIngredients,
    );
  }
}

class RecipeGenerating extends RecipeState {
  const RecipeGenerating();
}

class RecipeGenerated extends RecipeState {
  final RecipeModel recipe;
  final Map<String, bool> checkedIngredients;

  const RecipeGenerated({
    required this.recipe,
    this.checkedIngredients = const {},
  });

  @override
  List<Object?> get props => [recipe, checkedIngredients];

  RecipeGenerated copyWith({
    RecipeModel? recipe,
    Map<String, bool>? checkedIngredients,
  }) {
    return RecipeGenerated(
      recipe: recipe ?? this.recipe,
      checkedIngredients: checkedIngredients ?? this.checkedIngredients,
    );
  }
}

class RecipeGeneratedWithInventory extends RecipeState {
  final RecipeModel recipe;
  final List<ProductModel> availableIngredients;
  final List<ProductModel> selectedIngredients;
  final Map<String, bool> checkedIngredients;

  const RecipeGeneratedWithInventory({
    required this.recipe,
    required this.availableIngredients,
    this.selectedIngredients = const [],
    this.checkedIngredients = const {},
  });

  @override
  List<Object?> get props =>
      [recipe, availableIngredients, selectedIngredients, checkedIngredients];

  RecipeGeneratedWithInventory copyWith({
    RecipeModel? recipe,
    List<ProductModel>? availableIngredients,
    List<ProductModel>? selectedIngredients,
    Map<String, bool>? checkedIngredients,
  }) {
    return RecipeGeneratedWithInventory(
      recipe: recipe ?? this.recipe,
      availableIngredients: availableIngredients ?? this.availableIngredients,
      selectedIngredients: selectedIngredients ?? this.selectedIngredients,
      checkedIngredients: checkedIngredients ?? this.checkedIngredients,
    );
  }
}

class RecipeError extends RecipeState {
  final String message;

  const RecipeError(this.message);

  @override
  List<Object> get props => [message];
}
