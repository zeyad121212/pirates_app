import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'province_feedback_screen.dart';

class ProvinceStatusScreen extends StatefulWidget {
  final String currentUserId;
  const ProvinceStatusScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<ProvinceStatusScreen> createState() => _ProvinceStatusScreenState();
}

class _ProvinceStatusScreenState extends State<ProvinceStatusScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];
  late StreamSubscription<List<Map<String, dynamic>>> _sub;
  final SupabaseService _service = SupabaseService();

  @override
  void initState() {
    super.initState();
    _sub = _service.subscribeToTrainingRequests().listen((data) {
      final filtered = data.where((r) {
        return r['creator_id']?.toString() == widget.currentUserId
            && (r['status'] == 'completed' || r['status'] == 'final_approved_central');
      }).toList();
      setState(() {
        requests = filtered;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _markNotDone(int id) async {
    await _service.updateTrainingRequestStatus(
      requestId: id,
      newStatus: 'province_not_done',
    );
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
            Text('التخصص: ${r['specialty']}'),
            Text('عدد المتدربين: ${r['trainee_count']}'),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProvinceFeedbackScreen(
                          requestId: r['id'] as int,
                        ),
                      ),
                    );
                  },
                  child: const Text('تم التدريب'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () => _markNotDone(r['id'] as int),
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
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (requests.isEmpty) return const Center(child: Text('لا توجد طلبات'));
    return Scaffold(
      appBar: AppBar(title: const Text('متابعة التنفيذ')),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) => _buildCard(requests[index]),
      ),
    );
  }
}
