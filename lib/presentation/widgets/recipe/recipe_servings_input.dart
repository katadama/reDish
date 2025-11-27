import 'package:flutter/material.dart';

class RecipeServingsInput extends StatelessWidget {
  final int servings;
  final ValueChanged<int> onChanged;
  final int minServings;
  final int maxServings;

  const RecipeServingsInput({
    super.key,
    required this.servings,
    required this.onChanged,
    this.minServings = 1,
    this.maxServings = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFF34744),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.remove, size: 20),
                color: Colors.white,
                onPressed: servings > minServings
                    ? () => onChanged(servings - 1)
                    : null,
              ),
            ),
            Expanded(
              child: Text(
                servings.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro',
                  color: Color(0xFF4A545A),
                ),
              ),
            ),
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFF34744),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, size: 20),
                color: Colors.white,
                onPressed: servings < maxServings
                    ? () => onChanged(servings + 1)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
