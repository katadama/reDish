import 'package:flutter/material.dart';
import 'package:coo_list/data/models/recipe_model.dart';

class RecipeIngredientsTab extends StatefulWidget {
  final RecipeModel recipe;
  final Map<String, bool> initialCheckedIngredients;
  final ValueChanged<Map<String, bool>> onCheckedIngredientsChanged;

  const RecipeIngredientsTab({
    super.key,
    required this.recipe,
    required this.initialCheckedIngredients,
    required this.onCheckedIngredientsChanged,
  });

  @override
  State<RecipeIngredientsTab> createState() => _RecipeIngredientsTabState();
}

class _RecipeIngredientsTabState extends State<RecipeIngredientsTab> {
  late Map<String, bool> _checkedIngredients;

  @override
  void initState() {
    super.initState();
    _checkedIngredients = Map<String, bool>.from(widget.initialCheckedIngredients);

    for (var ingredient in widget.recipe.ingredients) {
      if (!_checkedIngredients.containsKey(ingredient.name)) {
        _checkedIngredients[ingredient.name] = false;
      }
    }
  }

  void _toggleIngredient(String ingredientName) {
    setState(() {
      _checkedIngredients[ingredientName] =
          !(_checkedIngredients[ingredientName] ?? false);
    });
    widget.onCheckedIngredientsChanged(Map<String, bool>.from(_checkedIngredients));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: const Row(
            children: [
              Text(
                'Hozzávalók',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro',
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
        ),

        ...widget.recipe.ingredients
            .map((ingredient) => _IngredientItem(
                  ingredient: ingredient,
                  isChecked: _checkedIngredients[ingredient.name] ?? false,
                  onTap: () => _toggleIngredient(ingredient.name),
                )),
      ],
    );
  }
}

class _IngredientItem extends StatelessWidget {
  final RecipeIngredient ingredient;
  final bool isChecked;
  final VoidCallback onTap;

  const _IngredientItem({
    required this.ingredient,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFFF9F9F9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: isChecked
              ? Border.all(color: const Color(0xFFE0E0E0), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFFF34744) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isChecked
                      ? const Color(0xFFF34744)
                      : const Color(0xFFCCCCCC),
                  width: 1.5,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      ingredient.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        color: isChecked ? Colors.grey : const Color(0xFF4A545A),
                        decoration:
                            isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ingredient.amount,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A545A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
