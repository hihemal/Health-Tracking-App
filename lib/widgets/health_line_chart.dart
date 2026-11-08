import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthLineChart extends StatelessWidget {
  final List<FlSpot> primarySpots;
  final List<FlSpot> secondarySpots;
  final bool showSecondary;

  const HealthLineChart({
    super.key,
    required this.primarySpots,
    this.secondarySpots = const [],
    this.showSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxX = (primarySpots.length - 1).toDouble();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX > 0 ? maxX : 1,
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            _createLine(primarySpots, Colors.teal),
            if (showSecondary)
              _createLine(secondarySpots, Colors.orange),
          ],
        ),
      ),
    );
  }

  LineChartBarData _createLine(
    List<FlSpot> spots,
    Color color,
  ) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: true),
    );
  }
}