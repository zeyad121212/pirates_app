import 'package:flutter/material.dart';
import 'contacts_screen.dart';
import 'approve_deny_requests_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'code_entry_screen.dart';

class CoordinatorScreen extends StatefulWidget {
  final String currentUserId;
  final String userRole;

  const CoordinatorScreen({
    super.key,
    required this.currentUserId,
    required this.userRole,
  });

  @override
  State<CoordinatorScreen> createState() => _CoordinatorScreenState();
}

class _CoordinatorScreenState extends State<CoordinatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central Coordinator Dashboard'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // زر متابعة الطلب
            Card(
              child: ListTile(
                title: const Text('متابعة الطلب'),
                trailing: const Icon(Icons.assignment),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApproveDenyRequestsScreen(
                        currentUserId: widget.currentUserId,
                        userRole: widget.userRole,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Training Calendar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Calendar view will be implemented here
            Card(
              child: ListTile(
                title: const Text('Manage Training Schedule'),
                subtitle: const Text('View and assign trainings'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  // TODO: Implement training schedule management
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Trainer Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Assign Trainers'),
                subtitle: const Text('Match trainers with training sessions'),
                trailing: const Icon(Icons.person_add),
                onTap: () {
                  // TODO: Implement trainer assignment
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Communication',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Messages'),
                subtitle: const Text('Communicate with team members'),
                trailing: const Icon(Icons.message),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ContactsScreen(
                            currentUserId: widget.currentUserId,
                            userRole: widget.userRole,
                          ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'مسؤول ملف التنمية',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // متابعة التطور التدريبي
                    },
                    child: const Text('متابعة التطور التدريبي'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // جمع البيانات من المحافظات
                    },
                    child: const Text('جمع البيانات من المحافظات'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Other Section',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Manage Training Schedule'),
                subtitle: const Text('View and assign trainings'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  // TODO: Implement training schedule management
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new training session creation
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
