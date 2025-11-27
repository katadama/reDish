import 'package:flutter/material.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/data/models/recipe_preferences_model.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_form_section.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_option_selector.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_option_selector_with_subtext.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_servings_input.dart';

class RecipeForm extends StatefulWidget {
  final List<ProductModel> availableIngredients;
  final RecipePreferencesModel initialPreferences;
  final Function(RecipePreferencesModel, List<ProductModel>) onGenerate;

  const RecipeForm({
    super.key,
    required this.availableIngredients,
    required this.initialPreferences,
    required this.onGenerate,
  });

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  late RecipePreferencesModel _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = widget.initialPreferences;
  }

  void _handleGenerate() {
    if (widget.availableIngredients.isEmpty) {
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

    widget.onGenerate(_preferences, widget.availableIngredients);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableIngredients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.no_food, size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Nincsenek hozzávalók',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adj hozzá alapanyagokat az otthoni készletedhez',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          RecipeFormSection(
            label: 'Konyha',
            child: RecipeOptionSelector(
              options: const [
                'Olasz',
                'Ázsiai',
                'Mexikói',
                'Francia',
                'Magyar',
                'Amerikai',
                'Közel-Kelet',
              ],
              selectedValue: _preferences.cuisine,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(cuisine: value);
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          RecipeFormSection(
            label: 'Elkészítési idő',
            child: RecipeOptionSelectorWithSubtext(
              options: const ['Gyors', 'Átlagos', 'Hosszú'],
              subtexts: const ['< 20 perc', '20-60 perc', '1-2 óra'],
              selectedValue: _preferences.preparationTime,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(preparationTime: value);
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          RecipeFormSection(
            label: 'Nehézség',
            child: RecipeOptionSelector(
              options: const ['Könnyű', 'Közepes', 'Nehéz'],
              selectedValue: _preferences.difficulty,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(difficulty: value);
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          RecipeFormSection(
            label: 'Fő',
            child: RecipeServingsInput(
              servings: _preferences.servings,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(servings: value);
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          RecipeFormSection(
            label: 'Étel fajta',
            child: RecipeOptionSelector(
              options: const ['Reggeli', 'Ebéd', 'Vacsora', 'Desszert'],
              selectedValue: _preferences.mealType,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(mealType: value);
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          RecipeFormSection(
            label: 'Generálás fajta',
            child: RecipeOptionSelector(
              options: const ['Lejárat Nélkül', 'Lejárattal'],
              selectedValue: _preferences.generationType,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(generationType: value);
                });
              },
            ),
          ),

          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: _handleGenerate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF34744),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                side: BorderSide(
                  color: const Color(0xFFF2F3FA).withValues(alpha: 0.5),
                  width: 2,
                ),
                elevation: 2,
              ),
              child: const Text(
                'Recept készítés',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
