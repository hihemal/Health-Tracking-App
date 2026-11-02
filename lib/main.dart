import 'auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tdmpqrwulbprkxbgqoyt.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRkbXBxcnd1bGJwcmt4Ymdxb3l0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM1NzUxNDksImV4cCI6MjEwOTE1MTE0OX0.1d71-ny9rFznPWYCCjBAcXBvLh1o-yLmyOzDwHAjPz4',
  );

  try {
  final response = await Supabase.instance.client
      .from('connection_test')
      .select();

  debugPrint('SUPABASE CONNECTION SUCCESS!');
  debugPrint(response.toString());
} catch (error) {
  debugPrint('SUPABASE CONNECTION FAILED: $error');
}

  runApp(const HTrackApp());
}

class HTrackApp extends StatelessWidget {
  const HTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Htrack26',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF167D91),
        ),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Htrack26',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, Patient!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Welcome to your health dashboard.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            const Text(
              'Health Overview',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: const [
                Expanded(
                  child: HealthCard(
                    title: 'Reports',
                    value: '05',
                    icon: Icons.description,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: HealthCard(
                    title: 'Health Status',
                    value: 'Good',
                    icon: Icons.favorite,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Recent Reports',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'View all',
                  style: TextStyle(color: Colors.teal),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const ReportCard(
              title: 'Blood Test',
              date: '01 November 2026',
              icon: Icons.bloodtype,
            ),

            const ReportCard(
              title: 'Liver Function Test',
              date: '28 October 2026',
              icon: Icons.science,
            ),

            const ReportCard(
              title: 'Kidney Function Test',
              date: '20 October 2026',
              icon: Icons.medical_services,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report upload feature coming soon!'),
            ),
          );
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Report'),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.description),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'Tracking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HealthCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const HealthCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.teal, size: 28),
            const SizedBox(height: 12),
            Text(title),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;

  const ReportCard({
    super.key,
    required this.title,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade50,
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(date),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
