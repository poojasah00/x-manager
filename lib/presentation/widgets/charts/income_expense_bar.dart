import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:x_manager/core/analytics_providers.dart';

class IncomeExpenseBar extends StatelessWidget {
  final List<MonthlyPoint> points;
  const IncomeExpenseBar({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final spotsIncome = <BarChartGroupData>[];
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      spotsIncome.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: p.income, color: Colors.green, width: 6),
            BarChartRodData(toY: p.expense, color: Colors.red, width: 6),
          ],
          barsSpace: 4,
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        barGroups: spotsIncome,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (i, meta) {
                final idx = i.toInt();
                if (idx < 0 || idx >= points.length) return const SizedBox();
                final label = DateFormat.MMM().format(points[idx].month);
                return Text(label, style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
      ),
    );
  }
}
