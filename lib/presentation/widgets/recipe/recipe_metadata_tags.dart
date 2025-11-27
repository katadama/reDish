import 'package:flutter/material.dart';
import 'package:coo_list/data/models/recipe_model.dart';

class RecipeMetadataTags extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeMetadataTags({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MetadataTag(
            icon: Icons.restaurant,
            label: recipe.cuisine,
            backgroundColor: const Color(0xFFFFF4F4),
            iconColor: const Color(0xFFF34744),
          ),
          const SizedBox(width: 8),
          _MetadataTag(
            icon: Icons.timer,
            label: '${recipe.preparationTimeMinutes} perc',
            backgroundColor: const Color(0xFFF5F8FF),
            iconColor: const Color(0xFF3498DB),
          ),
          const SizedBox(width: 8),
          _MetadataTag(
            icon: Icons.people,
            label: '${recipe.servings} fő',
            backgroundColor: const Color(0xFFF4FFF6),
            iconColor: const Color(0xFF2ECC71),
          ),
          const SizedBox(width: 8),
          _MetadataTag(
            icon: Icons.trending_up,
            label: recipe.difficulty,
            backgroundColor: const Color(0xFFFFF9F4),
            iconColor: const Color(0xFFE67E22),
          ),
          const SizedBox(width: 8),
          _MetadataTag(
            icon: Icons.category,
            label: recipe.mealType,
            backgroundColor: const Color(0xFFF4F6FF),
            iconColor: const Color(0xFF9B59B6),
          ),
        ],
      ),
    );
  }
}

class _MetadataTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;

  const _MetadataTag({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A545A),
            ),
          ),
        ],
      ),
    );
  }
}
