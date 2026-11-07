
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tdmpqrwulbprkxbgqoyt.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRkbXBxcnd1bGJwcmt4Ymdxb3l0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM1NzUxNDksImV4cCI6MjEwOTE1MTE0OX0.1d71-ny9rFznPWYCCjBAcXBvLh1o-yLmyOzDwHAjPz4',
  );

  // Test Supabase database connection
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
  final Widget? home;

  const HTrackApp({
    super.key,
    this.home,
  });

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
      home: home ?? const AuthScreen(),
    );
  }
}
