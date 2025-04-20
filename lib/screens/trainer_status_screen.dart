import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'trainer_feedback_screen.dart';

class TrainerStatusScreen extends StatefulWidget {
  final String currentUserId;
  const TrainerStatusScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<TrainerStatusScreen> createState() => _TrainerStatusScreenState();
}

class _TrainerStatusScreenState extends State<TrainerStatusScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];
  late StreamSubscription<List<Map<String, dynamic>>> _subscription;
  final SupabaseService _service = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _subscription = _service
        .subscribeToTrainingRequests()
        .listen((_) => _loadRequests());
  }

  Future<void> _loadRequests() async {
    setState(() => isLoading = true);
    final data = await _service.getApprovedRequestsForTrainer(widget.currentUserId);
    setState(() {
      requests = data;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Widget _buildCard(Map<String, dynamic> r) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r['province'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('التخصص: ${r['specialty']}'),
            Text('عدد المتدربين: ${r['trainee_count']}'),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrainerFeedbackScreen(requestId: r['id'] as int),
                      ),
                    );
                  },
                  child: const Text('تم التدريب'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () async {
                    await _service.updateTrainingRequestStatus(
                      requestId: r['id'] as int,
                      newStatus: 'trainer_not_done',
                    );
                    _loadRequests();
                  },
                  child: const Text('لم يتم التدريب'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مهام المدرب')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('لا توجد طلبات'))
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) => _buildCard(requests[index]),
                  ),
                ),
    );
  }
}
