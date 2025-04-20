import 'package:flutter/material.dart';
import 'trainer_requests_screen.dart';
import 'trainer_completion_screen.dart';

class TrainerDashboardScreen extends StatelessWidget {
  final int currentUserId;
  const TrainerDashboardScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: const Text('New Training Requests'),
                trailing: const Icon(Icons.assignment),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrainerRequestsScreen(currentUserId: currentUserId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Record Training Completion'),
                trailing: const Icon(Icons.check_circle),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrainerCompletionScreen(currentUserId: currentUserId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
