import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:victus_app/core/theme/app_colors.dart';

class StatChart extends StatelessWidget {
  final List<double> dataPoints;
  final double maxY;

  const StatChart({
    Key? key,
    required this.dataPoints,
    required this.maxY,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const SizedBox(height: 100);
    }

    final spots = dataPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    return SizedBox(
      height: 100,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: spots.length.toDouble() - 1,
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.textPrimary,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.surfaceVariant.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
