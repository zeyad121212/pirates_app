import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pirates_app/screens/code_entry_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://hkiqiuzogusamshprmnl.supabase.co',  // استخدم الـ URL الخاص بمشروعك
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhraXFpdXpvZ3VzYW1zaHBybW5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5Mjg1MjUsImV4cCI6MjA2MDUwNDUyNX0.xx27r8rIq0YuYg5_3P3EV5qS8Q6p5z-MSCR85WMy8_Q',  // استخدم الـ API Key الخاص بمشروعك
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Demo',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const CodeEntryScreen(),
    );
  }
}
