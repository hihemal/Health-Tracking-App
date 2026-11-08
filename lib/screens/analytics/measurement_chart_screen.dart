import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/analytics/health_record_service.dart';
import '../../utils/health_stats.dart';
import '../../widgets/health_line_chart.dart';

class MeasurementChartScreen extends StatelessWidget {
  final String recordType;
  final String title;
  final String unit;

  const MeasurementChartScreen({
    super.key,
    required this.recordType,
    required this.title,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: HealthRecordService().getRecords(recordType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(
              child: Text('No records available yet.'),
            );
          }

          final values = records
              .map((r) => (r['value'] as num).toDouble())
              .toList();

          final spots = values
              .asMap()
              .entries
              .map((e) => FlSpot(
                    e.key.toDouble(),
                    e.value,
                  ))
              .toList();

          final secondarySpots = records
              .asMap()
              .entries
              .where((e) => e.value['secondary_value'] != null)
              .map((e) => FlSpot(
                    e.key.toDouble(),
                    (e.value['secondary_value'] as num).toDouble(),
                  ))
              .toList();

          final isBloodPressure = recordType == 'blood_pressure';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Measurement Trend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      HealthLineChart(
                        primarySpots: spots,
                        secondarySpots: secondarySpots,
                        showSecondary: isBloodPressure &&
                            secondarySpots.isNotEmpty,
                      ),
                      if (isBloodPressure) ...[
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('● Systolic  ',
                                style: TextStyle(color: Colors.teal)),
                            Text('● Diastolic',
                                style: TextStyle(color: Colors.orange)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _statRow(
                        'Average',
                        HealthStats.average(values),
                        unit,
                      ),
                      _statRow(
                        'Minimum',
                        HealthStats.minimum(values),
                        unit,
                      ),
                      _statRow(
                        'Maximum',
                        HealthStats.maximum(values),
                        unit,
                      ),
                      _statRow(
                        'Total records',
                        values.length.toDouble(),
                        '',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}