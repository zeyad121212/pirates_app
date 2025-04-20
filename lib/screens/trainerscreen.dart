import 'package:flutter/material.dart';
import '../screens/contacts_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'code_entry_screen.dart';

class TrainerScreen extends StatelessWidget {
  final String currentUserId;
  final String userRole;

  const TrainerScreen({
    super.key,
    required this.currentUserId,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مدرب"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => CodeEntryScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // عرض مواعيد التدريب
              },
              child: Text('عرض مواعيد التدريب'),
            ),
            ElevatedButton(
              onPressed: () {
                // رفع تقارير التدريب
              },
              child: Text('رفع تقرير تدريب'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ContactsScreen(
                          currentUserId: currentUserId,
                          userRole: userRole,
                        ),
                  ),
                );
              },
              child: Text('المحادثات'),
            ),
          ],
        ),
      ),
    );
  }
}
