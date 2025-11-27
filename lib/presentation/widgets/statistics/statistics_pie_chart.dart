import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:coo_list/presentation/widgets/statistics/statistics_legend.dart';
import 'package:coo_list/presentation/widgets/statistics/statistics_empty_state.dart';

class PieChartSection {
  final String label;
  final Color color;
  final double value;
  final int count;

  const PieChartSection({
    required this.label,
    required this.color,
    required this.value,
    required this.count,
  });
}

class StatisticsPieChart extends StatelessWidget {
  final List<PieChartSection> sections;
  final List<LegendItem> legendItems;
  final double centerSpaceRadius;
  final double sectionsSpace;

  const StatisticsPieChart({
    super.key,
    required this.sections,
    required this.legendItems,
    this.centerSpaceRadius = 40,
    this.sectionsSpace = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const StatisticsEmptyState(
        message: 'Nincs elérhető adat',
        icon: Icons.pie_chart,
      );
    }

    final totalValue = sections.fold(0.0, (sum, section) => sum + section.value);

    final pieSections = sections.map((section) {
      final percentage = totalValue > 0 ? section.value / totalValue : 0.0;
      return PieChartSectionData(
        color: section.color,
        value: section.value,
        title: '${(percentage * 100).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: pieSections,
                centerSpaceRadius: centerSpaceRadius,
                sectionsSpace: sectionsSpace,
              ),
            ),
          ),
          const SizedBox(height: 16),
          StatisticsLegend(items: legendItems),
        ],
      ),
    );
  }
}
