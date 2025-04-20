import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/training_request_status.dart';

class TrainerCompletionScreen extends StatefulWidget {
  final int currentUserId;
  const TrainerCompletionScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _TrainerCompletionScreenState createState() => _TrainerCompletionScreenState();
}

class _TrainerCompletionScreenState extends State<TrainerCompletionScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => isLoading = true);
    try {
      final all = await _supabaseService.getTrainingRequests();
      final pending = all.where((r) {
        final status = TrainingRequestStatus.fromCode((r['status'] as String?) ?? '');
        final tid = r['trainer_selected_id'] as int?;
        return status == TrainingRequestStatus.trainerSelected && tid == widget.currentUserId;
      }).toList();
      setState(() {
        requests = pending;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Trainer Completion')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('No assigned trainings'))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final r = requests[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('Request #${r['id']}'),
                        subtitle: Text('Province: ${r['province']}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrainerCompletionForm(
                                  requestId: r['id'] as int,
                                  onSaved: _loadRequests,
                                ),
                              ),
                            );
                          },
                          child: const Text('Record Completion'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class TrainerCompletionForm extends StatefulWidget {
  final int requestId;
  final VoidCallback onSaved;
  const TrainerCompletionForm({Key? key, required this.requestId, required this.onSaved}) : super(key: key);

  @override
  _TrainerCompletionFormState createState() => _TrainerCompletionFormState();
}

class _TrainerCompletionFormState extends State<TrainerCompletionForm> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'completed';
  final TextEditingController _feedbackCtrl = TextEditingController();
  int _rating = 5;
  bool _submitting = false;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Completion Form')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['completed', 'not_completed']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              TextFormField(
                controller: _feedbackCtrl,
                decoration: const InputDecoration(labelText: 'Feedback'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Rating:'),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: _rating,
                    items: List.generate(5, (i) => i + 1)
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (v) => setState(() => _rating = v!),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _submitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _submitting = true);
                        await _supabaseService.recordTrainerCompletion(
                          requestId: widget.requestId,
                          completionStatus: _status,
                          feedback: _feedbackCtrl.text.trim(),
                          rating: _rating,
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Saved')));
                        widget.onSaved();
                        Navigator.pop(context);
                      },
                      child: const Text('Submit'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
