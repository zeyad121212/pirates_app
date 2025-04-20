import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../screens/trainer_completion_screen.dart';

class TrainerRequestsScreen extends StatefulWidget {
  final int currentUserId;
  const TrainerRequestsScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _TrainerRequestsScreenState createState() => _TrainerRequestsScreenState();
}

class _TrainerRequestsScreenState extends State<TrainerRequestsScreen> {
  final _supabaseService = SupabaseService();
  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];
  Map<int, List<Map<String, dynamic>>> responsesMap = {};
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    // subscribe to real-time training_requests updates
    _subscription = _supabaseService
        .subscribeToTrainingRequests()
        .listen((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await _supabaseService.getTrainingRequests();
      final pending = data
          .where((r) => (r['status'] as String) == 'pending_trainers')
          .toList();
      Map<int, List<Map<String, dynamic>>> map = {};
      for (var req in pending) {
        final resp = await _supabaseService
            .getTrainingRequestResponses(req['id'] as int);
        map[req['id'] as int] = resp;
      }
      setState(() {
        requests = pending;
        responsesMap = map;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load: $e')));
    }
  }

  Future<void> _approve(int requestId) async {
    await _supabaseService.createTrainingRequestResponse(
      requestId: requestId,
      trainerId: widget.currentUserId,
      response: 'approved',
    );
    // Notify monitoring agent
    final req = requests.firstWhere((r) => r['id'] == requestId);
    final monitorId = req['monitoring_agent_id'] as int?;
    if (monitorId != null) {
      await _supabaseService.createNotification(
        userId: monitorId.toString(),
        title: 'Trainer Approved',
        content: 'Trainer ${widget.currentUserId} approved request #$requestId',
        type: 'trainer_response',
      );
    }
    _loadData();
  }

  Future<void> _deny(int requestId) async {
    await _supabaseService.createTrainingRequestResponse(
      requestId: requestId,
      trainerId: widget.currentUserId,
      response: 'denied',
    );
    // check if all responses are denied
    final allResp = await _supabaseService.getTrainingRequestResponses(requestId);
    final hasApproved = allResp.any((r) => r['response'] == 'approved');
    if (!hasApproved && allResp.isNotEmpty) {
      // bulk update status
      await _supabaseService.updateTrainingRequestStatus(
        requestId: requestId,
        newStatus: 'denied_trainers',
      );
      // notify PM and province manager
      final req = requests.firstWhere((r) => r['id'] == requestId);
      final pmId = req['project_manager_id'] as int?;
      final provId = req['creator_id'] as int?;
      if (pmId != null) {
        await _supabaseService.createNotification(
          userId: pmId.toString(),
          title: 'Request Denied by Trainers',
          content: 'All trainers denied request #$requestId',
          type: 'denied_trainers',
        );
      }
      if (provId != null) {
        await _supabaseService.createNotification(
          userId: provId.toString(),
          title: 'Request Denied',
          content: 'Your request #$requestId was denied by all trainers',
          type: 'denied_trainers',
        );
      }
    }
    _loadData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات المدربين')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Navigate to trainer completion
                Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: const Text('سجل إكمال التدريب'),
                    trailing: const Icon(Icons.check_circle_outline),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrainerCompletionScreen(currentUserId: widget.currentUserId),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: requests.isEmpty
                      ? const Center(child: Text('لا توجد طلبات جديدة'))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              final r = requests[index];
                              return Card(
                                margin: const EdgeInsets.all(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r['province'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('التخصص: ${r['specialty']}'),
                                      Text('عدد المتدربين: ${r['trainee_count']}'),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green),
                                            onPressed: () => _approve(r['id'] as int),
                                            child: const Text('Approve'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            onPressed: () => _deny(r['id'] as int),
                                            child: const Text('Deny'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
