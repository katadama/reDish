import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/data/models/recipe_preferences_model.dart';
import 'package:coo_list/data/repositories/list_item_repository.dart';
import 'package:coo_list/data/repositories/recipe_repository.dart';
import 'package:coo_list/logic/recipe/recipe_bloc.dart';
import 'package:coo_list/logic/recipe/recipe_event.dart';
import 'package:coo_list/logic/recipe/recipe_state.dart';
import 'package:coo_list/presentation/screens/main_navigation_screen.dart';
import 'package:coo_list/presentation/widgets/recipe_result_content.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_form.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_generating_indicator.dart';

class RecipeScreen extends StatefulWidget {
  static const String routeName = '/recipe';

  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late RecipeBloc _recipeBloc;
  late RecipePreferencesModel _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = const RecipePreferencesModel();

    try {
      _recipeBloc = BlocProvider.of<RecipeBloc>(context);
    } catch (e) {
      _recipeBloc = RecipeBloc(
        listItemRepository: RepositoryProvider.of<ListItemRepository>(context),
        recipeRepository: RepositoryProvider.of<RecipeRepository>(context),
      )..add(const LoadHomeInventory());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _recipeBloc,
      child: BlocConsumer<RecipeBloc, RecipeState>(
        listener: (context, state) {
          if (state is RecipeError) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isRecipeGenerated =
              state is RecipeGenerated || state is RecipeGeneratedWithInventory;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              final MainNavigationScreenState? mainNavState =
                  context.findAncestorStateOfType<MainNavigationScreenState>();
              if (mainNavState != null) {
                mainNavState.updateRecipeState(isRecipeGenerated);
              }
            }
          });

          return Scaffold(
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, RecipeState state) {
    if (state is RecipeLoadingInventory) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF34744),
        ),
      );
    }

    if (state is RecipeInventoryLoaded) {
      return RecipeForm(
        availableIngredients: state.availableIngredients,
        initialPreferences: _preferences,
        onGenerate: (preferences, ingredients) {
          setState(() {
            _preferences = preferences;
          });
          _generateRecipe(preferences, ingredients);
        },
      );
    }

    if (state is RecipeGenerating) {
      return const RecipeGeneratingIndicator();
    }

    if (state is RecipeGenerated) {
      return RecipeResultContent(
        recipe: state.recipe,
        recipeBloc: _recipeBloc,
      );
    }

    if (state is RecipeGeneratedWithInventory) {
      return RecipeResultContent(
        recipe: state.recipe,
        recipeBloc: _recipeBloc,
      );
    }

    _recipeBloc.add(const LoadHomeInventory());

    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFF34744),
      ),
    );
  }

  void _generateRecipe(
    RecipePreferencesModel preferences,
    List<ProductModel> availableIngredients,
  ) {
    if (availableIngredients.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nincsenek hozzávalók az otthoni készletedben.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (preferences.generationType == 'Lejárattal') {
      _recipeBloc.add(GenerateRecipeWithSpoilage(
        selectedIngredients: availableIngredients,
        cuisine: preferences.cuisine,
        preparationTime: preferences.preparationTime,
        servings: preferences.servings,
        difficulty: preferences.difficulty,
        mealType: preferences.mealType,
      ));
    } else {
      _recipeBloc.add(GenerateRecipe(
        selectedIngredients: availableIngredients,
        cuisine: preferences.cuisine,
        preparationTime: preferences.preparationTime,
        servings: preferences.servings,
        difficulty: preferences.difficulty,
        mealType: preferences.mealType,
      ));
    }
  }
}
