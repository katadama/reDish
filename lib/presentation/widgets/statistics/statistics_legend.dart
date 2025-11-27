import 'package:flutter/material.dart';

class LegendItem {
  final String title;
  final Color color;
  final int count;
  final String? unit;

  const LegendItem({
    required this.title,
    required this.color,
    required this.count,
    this.unit,
  });
}

class StatisticsLegend extends StatelessWidget {
  final List<LegendItem> items;

  const StatisticsLegend({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: items.map((item) => _buildLegendItem(context, item)).toList(),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, LegendItem item) {
    final displayText = item.unit != null
        ? '${item.count} ${item.unit}'
        : '${item.count} items';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            displayText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}
