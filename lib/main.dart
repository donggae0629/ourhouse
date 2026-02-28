import 'package:flutter/material.dart';
import 'package:ourhouse2/views/LandingPage.dart';
import 'package:ourhouse2/views/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://guccfiyxejkowvqsyubb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd1Y2NmaXl4ZWprb3d2cXN5dWJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwMTc5NDIsImV4cCI6MjA4NzU5Mzk0Mn0.7HT0ZXGb185W1VrDqGrWfgXl0q4cuWFWI14oHeNSsqk',
  );
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const LandingPage(),
    );
  }
}



