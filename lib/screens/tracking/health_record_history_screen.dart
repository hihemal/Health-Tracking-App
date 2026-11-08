
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthRecordHistoryScreen extends StatefulWidget {
  const HealthRecordHistoryScreen({super.key});

  @override
  State<HealthRecordHistoryScreen> createState() =>
      _HealthRecordHistoryScreenState();
}

class _HealthRecordHistoryScreenState
    extends State<HealthRecordHistoryScreen> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _loadRecords();
  }

  Future<List<Map<String, dynamic>>> _loadRecords() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Please log in to view your health records.');
    }

    final response = await supabase
        .from('health_records')
        .select()
        .eq('user_id', user.id)
        .order('recorded_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  void _refreshRecords() {
    setState(() {
      _recordsFuture = _loadRecords();
    });
  }

  String _formatDate(dynamic date) {
    final parsedDate = DateTime.parse(date.toString()).toLocal();

    final day = parsedDate.day.toString().padLeft(2, '0');
    final month = parsedDate.month.toString().padLeft(2, '0');
    final year = parsedDate.year;

    final hour = parsedDate.hour % 12 == 0
        ? 12
        : parsedDate.hour % 12;
    final minute = parsedDate.minute.toString().padLeft(2, '0');
    final period = parsedDate.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year  $hour:$minute $period';
  }

  String _formatName(String value) {
    return value
        .split('_')
        .map((word) =>
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatValue(Map<String, dynamic> record) {
    final value = record['value'];
    final secondary = record['secondary_value'];
    final unit = record['unit'] ?? '';

    if (secondary != null) {
      return '$value/$secondary $unit';
    }

    return '$value $unit';
  }

  Future<void> _deleteRecord(Map<String, dynamic> record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete health record?'),
        content: const Text(
          'This record will be permanently deleted. '
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await supabase
          .from('health_records')
          .delete()
          .eq('id', record['id']);

      if (!mounted) return;

      _refreshRecords();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete record: $error')),
      );
    }
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final recordType = record['record_type']?.toString() ?? 'unknown';
    final category = record['category']?.toString() ?? 'other';
    final notes = record['notes']?.toString();

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(
                    Icons.monitor_heart_outlined,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatName(recordType),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatName(category),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Delete record',
                  onPressed: () => _deleteRecord(record),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _formatValue(record),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatDate(record['recorded_at']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Notes: $notes',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Source: ${record['source'] ?? 'unknown'}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text('Health Record History'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh records',
            onPressed: _refreshRecords,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 45,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text('Could not load health records.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshRecords,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 55,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No health records yet.',
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(height: 6),
                    Text('Your saved measurements will appear here.'),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final future = _loadRecords();
              setState(() {
                _recordsFuture = future;
              });
              await future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${records.length} health record(s)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                ...records.map(_buildRecordCard),
              ],
            ),
          );
        },
      ),
    );
  }
}
