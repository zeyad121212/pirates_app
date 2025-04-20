import 'package:flutter/material.dart';
import '../province_request_screen.dart';
import 'training_requests_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'code_entry_screen.dart';

class ProvinceManagerScreen extends StatelessWidget {
  final String currentUserId;
  final String userRole;

  const ProvinceManagerScreen({
    Key? key,
    required this.currentUserId,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مسؤول المحافظة"),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProvinceRequestScreen()),
                );
              },
              child: Text('إرسال طلب تدريب'),
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }
}
