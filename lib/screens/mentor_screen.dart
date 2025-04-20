import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class MentorScreen extends StatefulWidget {
  final int currentUserId;
  const MentorScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _MentorScreenState createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];
  Map<int, List<Map<String, dynamic>>> mentorsMap = {};
  Map<int, int?> selectedMentor = {};
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final all = await _supabaseService.getTrainingRequests();
      final pending = all.where((r) => r['monitoring_agent_id'] == null).toList();
      Map<int, List<Map<String, dynamic>>> mMap = {};
      for (var r in pending) {
        mMap[r['id'] as int] = await _supabaseService.getMentorsBySpecialty(r['specialty'] as String);
      }
      setState(() {
        requests = pending;
        mentorsMap = mMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
    }
  }

  Future<void> _assign(int requestId) async {
    final mentorId = selectedMentor[requestId];
    if (mentorId == null) return;
    await _supabaseService.assignMentor(requestId: requestId, mentorId: mentorId);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mentor assigned')));
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Mentors')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('No requests to assign'))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final r = requests[index];
                    final mentors = mentorsMap[r['id'] as int] ?? [];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Request #${r['id']} - ${r['specialty']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            DropdownButton<int>(
                              hint: const Text('Select Mentor'),
                              value: selectedMentor[r['id'] as int],
                              items: mentors
                                  .map((m) => DropdownMenuItem(
                                      value: m['id'] as int,
                                      child: Text(m['name'] as String? ?? 'Mentor #${m['id']}')))
                                  .toList(),
                              onChanged: (v) => setState(() => selectedMentor[r['id'] as int] = v),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _assign(r['id'] as int),
                              child: const Text('Assign'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
