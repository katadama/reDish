import 'package:flutter/material.dart';
import 'package:coo_list/data/models/recipe_model.dart';

class RecipePreparationTab extends StatelessWidget {
  final RecipeModel recipe;

  const RecipePreparationTab({
    super.key,
    required this.recipe,
  });

  List<MapEntry<String, String>> _getSortedInstructions() {
    final sortedInstructions = recipe.instructions.entries.toList()
      ..sort((a, b) {
        try {
          final aNum = int.parse(a.key);
          final bNum = int.parse(b.key);
          return aNum.compareTo(bNum);
        } catch (e) {
          return a.key.compareTo(b.key);
        }
      });
    return sortedInstructions;
  }

  @override
  Widget build(BuildContext context) {
    final sortedInstructions = _getSortedInstructions();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sortedInstructions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: const Row(
              children: [
                Text(
                  'Elkészítési lépések',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro',
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          );
        }

        final instruction = sortedInstructions[index - 1];
        return _StepItem(
          stepNumber: instruction.key,
          instruction: instruction.value,
        );
      },
    );
  }
}

class _StepItem extends StatelessWidget {
  final String stepNumber;
  final String instruction;

  const _StepItem({
    required this.stepNumber,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF34744),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro',
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                color: Color(0xFF4A545A),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
