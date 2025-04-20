import 'package:flutter/material.dart';
import 'contacts_screen.dart';
import 'training_requests_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'code_entry_screen.dart';

class MentorScreen extends StatelessWidget {
  final String currentUserId;
  final String userRole;
  const MentorScreen({super.key, required this.currentUserId, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مرشد'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrainingRequestsScreen(
                        currentUserId: currentUserId,
                        userRole: userRole,
                      ),
                    ),
                  );
                },
                child: const Text('متابعة الطلب'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // TODO: مراقبة الأداء
                },
                child: const Text('مراقبة الأداء'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                // TODO: تقييم المدربين
              },
                child: const Text('تقييم المدربين'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // TODO: تغذية راجعة للمدربين
                },
                child: const Text('تغذية راجعة للمدربين'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactsScreen(
                        currentUserId: currentUserId,
                        userRole: userRole,
                      ),
                    ),
                  );
                },
                child: const Text('المحادثات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
