import 'package:flutter/material.dart';
import 'training_requests_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'code_entry_screen.dart';

class SupervisorScreen extends StatefulWidget {
  final String currentUserId;
  final String userRole;

  const SupervisorScreen({
    super.key,
    required this.currentUserId,
    required this.userRole,
  });

  @override
  State<SupervisorScreen> createState() => _SupervisorScreenState();
}

class _SupervisorScreenState extends State<SupervisorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Dashboard'),
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
            const Text(
              'Training Requests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('متابعة الطلب'),
                trailing: const Icon(Icons.assignment),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrainingRequestsScreen(
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
              'Regional Trainers',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Manage Regional Trainers'),
                subtitle: const Text('View and manage trainer assignments'),
                trailing: const Icon(Icons.people),
                onTap: () {
                  // TODO: Implement regional trainer management
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Training Implementation Reports'),
                subtitle: const Text('View training progress and feedback'),
                trailing: const Icon(Icons.analytics),
                onTap: () {
                  // TODO: Implement reports viewing
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
                  // TODO: Implement messaging
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new training request creation
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
