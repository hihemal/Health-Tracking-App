import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/health_card.dart';
import '../../widgets/report_card.dart';

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
  actions: [
    const Padding(
      padding: EdgeInsets.only(right: 8),
      child: CircleAvatar(
        child: Icon(Icons.person),
      ),
    ),
    IconButton(
      tooltip: 'Sign Out',
      icon: const Icon(Icons.logout),
      onPressed: () async {
        try {
          await Supabase.instance.client.auth.signOut();
        } catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not sign out. Please try again.'),
              ),
            );
          }
        }
      },
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
