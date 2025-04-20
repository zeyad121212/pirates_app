import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'screens/training_requests_screen.dart';

class ProvinceRequestScreen extends StatefulWidget {
  const ProvinceRequestScreen({super.key});

  @override
  _ProvinceRequestScreenState createState() => _ProvinceRequestScreenState();
}

class _ProvinceRequestScreenState extends State<ProvinceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _provinces = [
    'القاهرة',
    'الإسكندرية',
    'الجيزة',
    'الشرقية',
    'الدقهلية',
    'القليوبية',
    'الغربية',
    'المنوفية',
    'البحيرة',
    'دمياط',
    'كفر الشيخ',
    'الفيوم',
    'بني سويف',
    'المنيا',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'البحر الأحمر',
    'شمال سيناء',
    'جنوب سيناء',
    'مطروح',
    'الوادي الجديد',
    'السويس',
    'بورسعيد',
    'الإسماعيلية',
    'أرقام',
    'أسيوط',
  ];
  final List<String> _specialties = [
    'العقلية',
    'العمل الجماعي',
    'التواصل الفعال',
  ];
  String? _selectedProvince;
  String? _selectedSpecialty;
  DateTime? _selectedDate;
  final TextEditingController _countCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  bool _submitting = false;

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await SupabaseService().createTrainingRequest(
        province: _selectedProvince!,
        traineeCount: int.parse(_countCtrl.text.trim()),
        specialty: _selectedSpecialty!,
        date: _dateCtrl.text.trim(),
      );
      _showMsg('تم إرسال الطلب بنجاح');
      _formKey.currentState!.reset();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TrainingRequestsScreen()),
      );
    } catch (e) {
      _showMsg('فشل الإرسال: $e');
      debugPrint('createTrainingRequest error: $e');
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب تدريب من المحافظة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'اسم المحافظة'),
                items:
                    _provinces
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                onChanged: (val) => setState(() => _selectedProvince = val),
                validator: (v) => v == null ? 'من فضلك اختر المحافظة' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _countCtrl,
                decoration: const InputDecoration(labelText: 'عدد المتدربين'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'من فضلك أدخل العدد' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'التخصص المطلوب'),
                items:
                    _specialties
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (val) => setState(() => _selectedSpecialty = val),
                validator: (v) => v == null ? 'من فضلك اختر التخصص' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'التاريخ المقترح'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _dateCtrl.text =
                          '${picked.day}/${picked.month}/${picked.year}';
                    });
                  }
                },
                validator: (v) => v!.isEmpty ? 'من فضلك اختر التاريخ' : null,
              ),
              const SizedBox(height: 20),
              _submitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _submitRequest,
                    child: const Text('إرسال الطلب'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
