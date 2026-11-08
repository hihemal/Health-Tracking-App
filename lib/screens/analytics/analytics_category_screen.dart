
import 'package:flutter/material.dart';

import 'measurement_chart_screen.dart';

class AnalyticsCategoryScreen extends StatelessWidget {
  final String categoryName;
  final List<Map<String, String>> measurements;

  const AnalyticsCategoryScreen({
    super.key,
    required this.categoryName,
    required this.measurements,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: measurements.length,
        itemBuilder: (context, index) {
          final measurement = measurements[index];

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.show_chart,
                  color: Colors.teal,
                ),
              ),
              title: Text(
                measurement['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Unit: ${measurement['unit']}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeasurementChartScreen(
                      recordType: measurement['recordType']!,
                      title: measurement['name']!,
                      unit: measurement['unit']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
