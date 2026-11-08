import 'health_record_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() =>
      _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _secondaryController = TextEditingController();
  final _notesController = TextEditingController();

  final supabase = Supabase.instance.client;

  String _selectedType = 'blood_pressure';
  bool _isSaving = false;

  final Map<String, Map<String, String>> _measurements = {
    'blood_pressure': {
      'name': 'Blood Pressure',
      'category': 'vital_signs',
      'unit': 'mmHg',
      'secondary': 'Diastolic value',
    },
    'heart_rate': {
      'name': 'Heart Rate',
      'category': 'vital_signs',
      'unit': 'bpm',
    },
    'spo2': {
      'name': 'Blood Oxygen (SpO2)',
      'category': 'vital_signs',
      'unit': '%',
    },
    'temperature': {
      'name': 'Body Temperature',
      'category': 'vital_signs',
      'unit': '°C',
    },
    'respiratory_rate': {
      'name': 'Respiratory Rate',
      'category': 'vital_signs',
      'unit': 'breaths/min',
    },
    'weight': {
      'name': 'Weight',
      'category': 'body_measurements',
      'unit': 'kg',
    },
    'height': {
      'name': 'Height',
      'category': 'body_measurements',
      'unit': 'cm',
    },
    'waist': {
      'name': 'Waist Circumference',
      'category': 'body_measurements',
      'unit': 'cm',
    },
    'blood_glucose_fasting': {
      'name': 'Fasting Blood Glucose',
      'category': 'blood_glucose',
      'unit': 'mg/dL',
    },
    'blood_glucose_random': {
      'name': 'Random Blood Glucose',
      'category': 'blood_glucose',
      'unit': 'mg/dL',
    },
    'hba1c': {
      'name': 'HbA1c',
      'category': 'blood_glucose',
      'unit': '%',
    },
    'cholesterol': {
      'name': 'Total Cholesterol',
      'category': 'laboratory',
      'unit': 'mg/dL',
    },
    'hdl': {
      'name': 'HDL Cholesterol',
      'category': 'laboratory',
      'unit': 'mg/dL',
    },
    'ldl': {
      'name': 'LDL Cholesterol',
      'category': 'laboratory',
      'unit': 'mg/dL',
    },
    'triglycerides': {
      'name': 'Triglycerides',
      'category': 'laboratory',
      'unit': 'mg/dL',
    },
    'hemoglobin': {
      'name': 'Hemoglobin',
      'category': 'laboratory',
      'unit': 'g/dL',
    },
    'daily_steps': {
      'name': 'Daily Steps',
      'category': 'lifestyle',
      'unit': 'steps',
    },
    'sleep_duration': {
      'name': 'Sleep Duration',
      'category': 'lifestyle',
      'unit': 'hours',
    },
    'water_intake': {
      'name': 'Water Intake',
      'category': 'lifestyle',
      'unit': 'liters',
    },
  };

  Map<String, String> get _currentMeasurement =>
      _measurements[_selectedType]!;

  bool get _needsSecondaryValue =>
      _selectedType == 'blood_pressure';

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage('Please log in first.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await supabase.from('health_records').insert({
        'user_id': user.id,
        'record_type': _selectedType,
        'category': _currentMeasurement['category'],
        'value': double.parse(_valueController.text.trim()),
        'secondary_value': _needsSecondaryValue
            ? double.parse(_secondaryController.text.trim())
            : null,
        'unit': _currentMeasurement['unit'],
        'source': 'manual',
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'recorded_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      _showMessage('Health record saved successfully!');
      _valueController.clear();
      _secondaryController.clear();
      _notesController.clear();
    } catch (error) {
      _showMessage('Could not save record: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _secondaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
  title: const Text('Health Tracking'),
  backgroundColor: Colors.white,
  actions: [
    IconButton(
      tooltip: 'View history',
      icon: const Icon(Icons.history),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HealthRecordHistoryScreen(),
          ),
        );
      },
    ),
  ],
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Health Measurement',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Measurement Type'),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _measurements.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedType = value;
                        _valueController.clear();
                        _secondaryController.clear();
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    _needsSecondaryValue
                        ? 'Systolic Value (${_currentMeasurement['unit']})'
                        : 'Value (${_currentMeasurement['unit']})',
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _valueController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'Enter measurement',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a value';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),

                  if (_needsSecondaryValue) ...[
                    const SizedBox(height: 16),
                    const Text('Diastolic Value (mmHg)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _secondaryController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Enter diastolic value',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_needsSecondaryValue &&
                            (value == null ||
                                double.tryParse(value.trim()) == null)) {
                          return 'Enter a valid diastolic value';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text('Notes (Optional)'),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add additional information',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Save Health Record'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
