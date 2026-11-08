
import 'package:flutter/material.dart';
import 'analytics_category_screen.dart';

class HealthAnalyticsScreen extends StatelessWidget {
  const HealthAnalyticsScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'Vital Signs',
      'description': 'Blood pressure, heart rate, oxygen and more',
      'icon': Icons.favorite,
      'color': Colors.red,
      'measurements': [
        {'name': 'Blood Pressure', 'recordType': 'blood_pressure', 'unit': 'mmHg'},
        {'name': 'Heart Rate', 'recordType': 'heart_rate', 'unit': 'bpm'},
        {'name': 'SpO2', 'recordType': 'spo2', 'unit': '%'},
        {'name': 'Temperature', 'recordType': 'temperature', 'unit': '°C'},
        {'name': 'Respiratory Rate', 'recordType': 'respiratory_rate', 'unit': 'breaths/min'},
      ],
    },
    {
      'name': 'Body Measurements',
      'description': 'Weight, height and waist measurements',
      'icon': Icons.monitor_weight,
      'color': Colors.blue,
      'measurements': [
        {'name': 'Weight', 'recordType': 'weight', 'unit': 'kg'},
        {'name': 'Height', 'recordType': 'height', 'unit': 'cm'},
        {'name': 'Waist', 'recordType': 'waist', 'unit': 'cm'},
      ],
    },
    {
      'name': 'Blood Glucose',
      'description': 'Track your blood sugar levels',
      'icon': Icons.water_drop,
      'color': Colors.orange,
      'measurements': [
        {'name': 'Fasting Glucose', 'recordType': 'blood_glucose_fasting', 'unit': 'mg/dL'},
        {'name': 'Random Glucose', 'recordType': 'blood_glucose_random', 'unit': 'mg/dL'},
      ],
    },
    {
      'name': 'Laboratory',
      'description': 'HbA1c, cholesterol and blood tests',
      'icon': Icons.science,
      'color': Colors.purple,
      'measurements': [
        {'name': 'HbA1c', 'recordType': 'hba1c', 'unit': '%'},
        {'name': 'Cholesterol', 'recordType': 'cholesterol', 'unit': 'mg/dL'},
        {'name': 'HDL', 'recordType': 'hdl', 'unit': 'mg/dL'},
        {'name': 'LDL', 'recordType': 'ldl', 'unit': 'mg/dL'},
        {'name': 'Triglycerides', 'recordType': 'triglycerides', 'unit': 'mg/dL'},
        {'name': 'Hemoglobin', 'recordType': 'hemoglobin', 'unit': 'g/dL'},
      ],
    },
    {
      'name': 'Lifestyle',
      'description': 'Sleep, daily steps and water intake',
      'icon': Icons.nightlight_round,
      'color': Colors.teal,
      'measurements': [
        {'name': 'Daily Steps', 'recordType': 'daily_steps', 'unit': 'steps'},
        {'name': 'Sleep Duration', 'recordType': 'sleep_duration', 'unit': 'hours'},
        {'name': 'Water Intake', 'recordType': 'water_intake', 'unit': 'liters'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text('Health Analytics'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Your Health Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a category to explore your health measurements.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          ...categories.map((category) {
            final measurements =
                List<Map<String, String>>.from(
              (category['measurements'] as List).map(
                (item) => Map<String, String>.from(item),
              ),
            );

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor:
                      (category['color'] as Color).withValues(alpha: 0.12),
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                  ),
                ),
                title: Text(
                  category['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    category['description'] as String,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnalyticsCategoryScreen(
                        categoryName: category['name'] as String,
                        measurements: measurements,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
