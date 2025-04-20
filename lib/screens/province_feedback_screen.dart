import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ProvinceFeedbackScreen extends StatefulWidget {
  final int requestId;
  const ProvinceFeedbackScreen({Key? key, required this.requestId}) : super(key: key);

  @override
  _ProvinceFeedbackScreenState createState() => _ProvinceFeedbackScreenState();
}

class _ProvinceFeedbackScreenState extends State<ProvinceFeedbackScreen> {
  final TextEditingController _feedbackCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    if (_feedbackCtrl.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    await SupabaseService().submitProvinceFeedback(
      requestId: widget.requestId,
      feedback: _feedbackCtrl.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملاحظات المحافظة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _feedbackCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'التغذية الراجعة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitFeedback,
                    child: const Text('إرسال الملاحظات'),
                  ),
          ],
        ),
      ),
    );
  }
}
