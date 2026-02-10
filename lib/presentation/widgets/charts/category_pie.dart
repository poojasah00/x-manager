import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:x_manager/core/analytics_providers.dart';

class CategoryPie extends StatelessWidget {
  final List<CategoryPoint> points;
  const CategoryPie({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final sections = points
        .asMap()
        .map((i, p) {
          final color = Colors.primaries[i % Colors.primaries.length];
          return MapEntry(
            i,
            PieChartSectionData(
              value: p.amount,
              title: p.categoryName,
              color: color,
              radius: 60,
            ),
          );
        })
        .values
        .toList();

    if (sections.isEmpty) return const Center(child: Text('No data'));

    return PieChart(
      PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 24),
    );
  }
}
