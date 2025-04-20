import 'package:flutter/material.dart';
import 'monitoring_agent_screen.dart';
import 'mentor_screen.dart';

class MonitoringAgentDashboardScreen extends StatelessWidget {
  final int currentUserId;
  const MonitoringAgentDashboardScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Agent Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: const Text('Review Trainer Responses'),
                trailing: const Icon(Icons.assignment),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MonitoringAgentScreen(currentUserId: currentUserId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Mentor Dashboard'),
                trailing: const Icon(Icons.person),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MentorScreen(currentUserId: currentUserId),
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
