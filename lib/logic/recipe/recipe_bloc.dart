import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/repositories/list_item_repository.dart';
import 'package:coo_list/data/repositories/recipe_repository.dart';
import 'package:coo_list/logic/recipe/recipe_event.dart';
import 'package:coo_list/logic/recipe/recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final ListItemRepository listItemRepository;
  final RecipeRepository recipeRepository;

  RecipeBloc({
    required this.listItemRepository,
    required this.recipeRepository,
  }) : super(const RecipeInitial()) {
    on<LoadHomeInventory>(_onLoadHomeInventory);
    on<GenerateRecipe>(_onGenerateRecipe);
    on<GenerateRecipeWithSpoilage>(_onGenerateRecipeWithSpoilage);
    on<ResetRecipeState>(_onResetRecipeState);
    on<UpdateCheckedIngredients>(_onUpdateCheckedIngredients);
  }

  Future<void> _onLoadHomeInventory(
    LoadHomeInventory event,
    Emitter<RecipeState> emit,
  ) async {
    final currentState = state;

    emit(const RecipeLoadingInventory());

    try {
      final homeInventory =
          await listItemRepository.getAllHomeInventoryForRecipes();

      if (currentState is RecipeGenerated) {
        emit(RecipeGeneratedWithInventory(
          recipe: currentState.recipe,
          availableIngredients: homeInventory,
        ));
      } else if (currentState is RecipeGeneratedWithInventory) {
        emit(currentState.copyWith(availableIngredients: homeInventory));
      } else {
        emit(RecipeInventoryLoaded(availableIngredients: homeInventory));
      }
    } catch (e) {
      emit(RecipeError('Nem sikerült betölteni a háztartási készletedet: $e'));
    }
  }

  Future<void> _onGenerateRecipe(
    GenerateRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    emit(const RecipeGenerating());

    try {
      final recipe = await recipeRepository.generateRecipe(
        ingredients: event.selectedIngredients,
        cuisine: event.cuisine,
        preparationTime: event.preparationTime,
        servings: event.servings,
        difficulty: event.difficulty,
        mealType: event.mealType,
      );

      if (recipe.error != null) {
        emit(RecipeError(recipe.error!));
      } else {
        Map<String, bool> existingCheckedIngredients = {};
        if (state is RecipeGenerated) {
          existingCheckedIngredients =
              (state as RecipeGenerated).checkedIngredients;
        } else if (state is RecipeGeneratedWithInventory) {
          existingCheckedIngredients =
              (state as RecipeGeneratedWithInventory).checkedIngredients;
        }

        if (state is RecipeInventoryLoaded) {
          final inventoryState = state as RecipeInventoryLoaded;
          emit(RecipeGeneratedWithInventory(
            recipe: recipe,
            availableIngredients: inventoryState.availableIngredients,
            selectedIngredients: inventoryState.selectedIngredients,
            checkedIngredients: existingCheckedIngredients,
          ));
        } else {
          emit(RecipeGenerated(
            recipe: recipe,
            checkedIngredients: existingCheckedIngredients,
          ));
        }
      }
    } catch (e) {
      emit(RecipeError('Nem sikerült generálni a receptet: $e'));
    }
  }

  Future<void> _onGenerateRecipeWithSpoilage(
    GenerateRecipeWithSpoilage event,
    Emitter<RecipeState> emit,
  ) async {
    emit(const RecipeGenerating());

    try {
      final recipe = await recipeRepository.generateRecipeWithSpoilage(
        ingredients: event.selectedIngredients,
        cuisine: event.cuisine,
        preparationTime: event.preparationTime,
        servings: event.servings,
        difficulty: event.difficulty,
        mealType: event.mealType,
      );

      if (recipe.error != null) {
        emit(RecipeError(recipe.error!));
      } else {
        Map<String, bool> existingCheckedIngredients = {};
        if (state is RecipeGenerated) {
          existingCheckedIngredients =
              (state as RecipeGenerated).checkedIngredients;
        } else if (state is RecipeGeneratedWithInventory) {
          existingCheckedIngredients =
              (state as RecipeGeneratedWithInventory).checkedIngredients;
        }

        if (state is RecipeInventoryLoaded) {
          final inventoryState = state as RecipeInventoryLoaded;
          emit(RecipeGeneratedWithInventory(
            recipe: recipe,
            availableIngredients: inventoryState.availableIngredients,
            selectedIngredients: inventoryState.selectedIngredients,
            checkedIngredients: existingCheckedIngredients,
          ));
        } else {
          emit(RecipeGenerated(
            recipe: recipe,
            checkedIngredients: existingCheckedIngredients,
          ));
        }
      }
    } catch (e) {
      emit(RecipeError(
          'Nem sikerült generálni a receptet a lejárás előnyben részesítésével: $e'));
    }
  }

  Future<void> _onResetRecipeState(
    ResetRecipeState event,
    Emitter<RecipeState> emit,
  ) async {
    if (state is RecipeGenerated || state is RecipeGeneratedWithInventory) {
      if (state is RecipeGeneratedWithInventory) {
        final generatedState = state as RecipeGeneratedWithInventory;
        emit(RecipeInventoryLoaded(
          availableIngredients: generatedState.availableIngredients,
          selectedIngredients: generatedState.selectedIngredients,
        ));
      } else {
        emit(const RecipeLoadingInventory());
        add(const LoadHomeInventory());
      }
    } else {
      emit(const RecipeInitial());
    }
  }

  void _onUpdateCheckedIngredients(
    UpdateCheckedIngredients event,
    Emitter<RecipeState> emit,
  ) {
    if (state is RecipeGenerated) {
      final currentState = state as RecipeGenerated;
      emit(currentState.copyWith(
        checkedIngredients: event.checkedIngredients,
      ));
    } else if (state is RecipeGeneratedWithInventory) {
      final currentState = state as RecipeGeneratedWithInventory;
      emit(currentState.copyWith(
        checkedIngredients: event.checkedIngredients,
      ));
    }
  }
}
