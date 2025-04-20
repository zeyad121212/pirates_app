import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class TrainerFeedbackScreen extends StatefulWidget {
  final int requestId;
  const TrainerFeedbackScreen({Key? key, required this.requestId}) : super(key: key);

  @override
  _TrainerFeedbackScreenState createState() => _TrainerFeedbackScreenState();
}

class _TrainerFeedbackScreenState extends State<TrainerFeedbackScreen> {
  final TextEditingController _feedbackCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_feedbackCtrl.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    await SupabaseService().submitTrainerFeedback(
      requestId: widget.requestId,
      feedback: _feedbackCtrl.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملاحظات المدرب')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _feedbackCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'تقرير اليوم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('إرسال التقرير'),
                  ),
          ],
        ),
      ),
    );
  }
}
