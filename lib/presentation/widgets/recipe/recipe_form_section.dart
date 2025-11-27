import 'package:flutter/material.dart';

class RecipeFormSection extends StatelessWidget {
  final String label;
  final Widget child;

  const RecipeFormSection({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF000000),
              fontFamily: 'SF Pro',
            ),
          ),
        ),
        child,
      ],
    );
  }
}
