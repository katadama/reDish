import 'package:flutter/material.dart';

class RecipeOptionSelectorWithSubtext extends StatelessWidget {
  final List<String> options;
  final List<String> subtexts;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const RecipeOptionSelectorWithSubtext({
    super.key,
    required this.options,
    required this.subtexts,
    required this.selectedValue,
    required this.onChanged,
  }) : assert(options.length == subtexts.length,
            'Az opciók és az alcímek hosszának meg kell egyeznie');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List.generate(options.length, (index) {
            return _OptionChipWithSubtext(
              label: options[index],
              subtext: subtexts[index],
              isSelected: options[index] == selectedValue,
              onSelected: () => onChanged(options[index]),
            );
          }),
        ),
      ),
    );
  }
}

class _OptionChipWithSubtext extends StatelessWidget {
  final String label;
  final String subtext;
  final bool isSelected;
  final VoidCallback onSelected;

  const _OptionChipWithSubtext({
    required this.label,
    required this.subtext,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF34744) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF34744)
                : const Color(0xFFF2F3FA),
            width: 1,
          ),
          boxShadow: isSelected
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4A545A),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFamily: 'SF Pro',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : const Color(0xFF4A545A).withValues(alpha: 0.7),
                fontSize: 10,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
