
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthAnalyticsScreen extends StatefulWidget {
  const HealthAnalyticsScreen({super.key});

  @override
  State<HealthAnalyticsScreen> createState() =>
      _HealthAnalyticsScreenState();
}

class _HealthAnalyticsScreenState
    extends State<HealthAnalyticsScreen> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _loadBloodPressureRecords();
  }

  // Fetch this patient's blood pressure records.
  Future<List<Map<String, dynamic>>>
      _loadBloodPressureRecords() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Please log in to view your analytics.');
    }

    final response = await supabase
        .from('health_records')
        .select('value, secondary_value, recorded_at')
        .eq('user_id', user.id)
        .eq('record_type', 'blood_pressure')
        .order('recorded_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  void _refreshRecords() {
    setState(() {
      _recordsFuture = _loadBloodPressureRecords();
    });
  }

  String _formatDate(dynamic value) {
    final date = DateTime.parse(value.toString()).toLocal();

    return '${date.day}/${date.month}';
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  Widget _buildBloodPressureChart(
      List<Map<String, dynamic>> records) {
    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];

    final allValues = <double>[];

    for (int i = 0; i < records.length; i++) {
      final systolic =
          (records[i]['value'] as num).toDouble();

      final diastolic =
          (records[i]['secondary_value'] as num?)
              ?.toDouble();

      systolicSpots.add(
        FlSpot(i.toDouble(), systolic),
      );

      allValues.add(systolic);

      if (diastolic != null) {
        diastolicSpots.add(
          FlSpot(i.toDouble(), diastolic),
        );

        allValues.add(diastolic);
      }
    }

    final minValue = allValues.reduce(
      (a, b) => a < b ? a : b,
    );

    final maxValue = allValues.reduce(
      (a, b) => a > b ? a : b,
    );

    final padding = ((maxValue - minValue) * 0.2)
        .clamp(10.0, 30.0);

    final interval =
        (records.length / 5).ceil().toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLegend(
              Colors.teal,
              'Systolic',
            ),
            const SizedBox(width: 20),
            _buildLegend(
              Colors.orange,
              'Diastolic',
            ),
          ],
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minY: minValue - padding,
              maxY: maxValue + padding,

              minX: 0,
              maxX: (records.length - 1).toDouble(),

              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
              ),

              borderData: FlBorderData(
                show: false,
              ),

              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),

                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),

                leftTitles: AxisTitles(
                  axisNameWidget: const Text('mmHg'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();

                      if (index < 0 ||
                          index >= records.length) {
                        return const SizedBox.shrink();
                      }

                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          _formatDate(
                            records[index]['recorded_at'],
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: systolicSpots,
                  isCurved: true,
                  color: Colors.teal,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: false,
                  ),
                ),

                LineChartBarData(
                  spots: diastolicSpots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),

      appBar: AppBar(
        title: const Text('Health Analytics'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshRecords,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Could not load health records:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No blood pressure records found.\n'
                  'Add some readings in Health Tracking '
                  'to see your graph.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Blood Pressure Trends',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${records.length} recorded measurements',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              Card(
                color: Colors.white,
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildBloodPressureChart(records),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Recent Readings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...records.reversed.take(5).map((record) {
                final systolic =
                    record['value'];

                final diastolic =
                    record['secondary_value'];

                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(
                      Icons.favorite,
                      color: Colors.teal,
                    ),
                    title: Text(
                      '$systolic / $diastolic mmHg',
                    ),
                    subtitle: Text(
                      _formatDate(record['recorded_at']),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
