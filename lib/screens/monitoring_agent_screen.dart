import 'package:flutter/material.dart';
import 'dart:async';
import '../services/supabase_service.dart';
import 'deny_reason_screen.dart';
import '../models/training_request_status.dart';
import 'mentor_screen.dart';

class MonitoringAgentScreen extends StatefulWidget {
  final int currentUserId;
  const MonitoringAgentScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _MonitoringAgentScreenState createState() => _MonitoringAgentScreenState();
}

class _MonitoringAgentScreenState extends State<MonitoringAgentScreen> {
  final _supabaseService = SupabaseService();
  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];
  Map<int, List<Map<String, dynamic>>> responsesMap = {};
  Map<int, int?> selectedTrainer = {};
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    // subscribe to real-time changes on training_requests
    _subscription = _supabaseService
        .subscribeToTrainingRequests()
        .listen((_) => _loadData());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await _supabaseService.getTrainingRequests();
      final pending = data.where((r) {
        final status = TrainingRequestStatus.fromCode((r['status'] as String?) ?? '');
        return status == TrainingRequestStatus.trainersResponded;
      }).toList();
      Map<int, List<Map<String, dynamic>>> map = {};
      for (var req in pending) {
        final resp = await _supabaseService.getTrainingRequestResponses(req['id'] as int);
        map[req['id'] as int] = resp;
      }
      setState(() {
        requests = pending;
        responsesMap = map;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load: $e')),
      );
    }
  }

  Future<void> _confirm(int requestId) async {
    final trainerId = selectedTrainer[requestId];
    if (trainerId == null) return;
    await _supabaseService.updateTrainingRequestStatus(
      requestId: requestId,
      newStatus: 'trainer_selected',
      trainerSelectedId: trainerId,
      monitoringAgentId: widget.currentUserId,
    );
    // notify project manager
    final req = requests.firstWhere((r) => r['id'] == requestId);
    final pmId = req['project_manager_id'] as int?;
    if (pmId != null) {
      await _supabaseService.createNotification(
        userId: pmId.toString(),
        title: 'Trainer Selected',
        content: 'Trainer #$trainerId selected for request #$requestId',
        type: 'trainer_selected',
      );
    }
    _loadData();
  }

  Future<void> _deny(int requestId) async {
    // open reason screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DenyReasonScreen(
          requestId: requestId,
          nextStatus: 'denied_agent',
        ),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Agent')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Mentor dashboard access
                Card(
                  child: ListTile(
                    title: const Text('Mentor Dashboard'),
                    trailing: const Icon(Icons.person),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MentorScreen(currentUserId: widget.currentUserId)),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: requests.isEmpty
                      ? const Center(child: Text('No requests to review'))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              final r = requests[index];
                              final resp = responsesMap[r['id']] ?? [];
                              final approved = resp.where((e) => e['response'] == 'approved').toList();
                              final trainers = approved.map((e) => e['trainer_id'] as int).toList();
                              return Card(
                                margin: const EdgeInsets.all(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Request #${r['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      trainers.isEmpty
                                          ? const Text('No trainers approved yet')
                                          : DropdownButton<int>(
                                              hint: const Text('Select Trainer'),
                                              value: selectedTrainer[r['id']],
                                              items: trainers
                                                  .map((t) => DropdownMenuItem(value: t, child: Text('Trainer #$t')))
                                                  .toList(),
                                              onChanged: (val) {
                                                setState(() => selectedTrainer[r['id']!] = val);
                                              },
                                            ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _confirm(r['id'] as int),
                                            child: const Text('Confirm'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
