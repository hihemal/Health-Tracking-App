import '../tracking/health_records_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/health_card.dart';
import '../../widgets/report_card.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;

  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  // Fetch the logged-in user's profile from Supabase.
  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final profile = await supabase
        .from('profiles')
        .select('full_name, role')
        .eq('id', user.id)
        .maybeSingle();

    return profile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),

      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Htrack26',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          // Profile Button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'My Profile',
              icon: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),

          // Sign Out Button
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await supabase.auth.signOut();
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not sign out. Please try again.',
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),

      // Dashboard Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Dynamic User Information
            FutureBuilder<Map<String, dynamic>?>(
              future: _profileFuture,
              builder: (context, snapshot) {
                final user = supabase.auth.currentUser;

                final metadataName =
                    user?.userMetadata?['full_name'] as String?;

                final profileName =
                    snapshot.data?['full_name'] as String?;

                final name = profileName ??
                    metadataName ??
                    'Patient';

                final role =
                    snapshot.data?['role'] as String? ?? 'patient';

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Text('Loading your profile...');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name!',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Role: ${role[0].toUpperCase()}${role.substring(1)}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Welcome to your health dashboard.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Health Overview
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

            // Recent Reports Heading
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

            // Report List
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

      // Upload Report Button
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

      // Bottom Navigation Bar (currently visual only)
      
bottomNavigationBar: NavigationBar(
  selectedIndex: 0,
  onDestinationSelected: (index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
    }
    if (index == 2) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const HealthRecordsScreen(),
    ),
  );
}
  },
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
