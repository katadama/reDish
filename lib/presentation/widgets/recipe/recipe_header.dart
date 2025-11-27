import 'package:flutter/material.dart';
import 'package:coo_list/data/models/recipe_model.dart';
import 'package:coo_list/presentation/widgets/recipe/recipe_metadata_tags.dart';

class RecipeHeader extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeHeader({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.recipeName,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              recipe.description,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                color: Color(0xFF4A545A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            RecipeMetadataTags(recipe: recipe),
          ],
        ),
      ),
    );
  }
}
