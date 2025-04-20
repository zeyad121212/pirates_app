import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class DenyReasonScreen extends StatefulWidget {
  final int requestId;
  final String nextStatus;

  const DenyReasonScreen({
    Key? key,
    required this.requestId,
    required this.nextStatus,
  }) : super(key: key);

  @override
  _DenyReasonScreenState createState() => _DenyReasonScreenState();
}

class _DenyReasonScreenState extends State<DenyReasonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سبب الرفض')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _reasonCtrl,
                decoration: const InputDecoration(labelText: 'سبب الرفض'),
                validator: (v) => v == null || v.isEmpty ? 'من فضلك اذكر سبب الرفض' : null,
              ),
              const SizedBox(height: 20),
              _submitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _submitting = true);
                        if (widget.nextStatus == 'denied_agent') {
                          await SupabaseService().rejectAllTrainerResponses(
                            requestId: widget.requestId,
                            denialReason: _reasonCtrl.text.trim(),
                          );
                        } else {
                          await SupabaseService().updateTrainingRequestStatus(
                            requestId: widget.requestId,
                            newStatus: widget.nextStatus,
                            denialReason: _reasonCtrl.text.trim(),
                          );
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('إرسال'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
