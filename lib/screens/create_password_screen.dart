import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String code;
  const CreatePasswordScreen({super.key, required this.code});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController  = TextEditingController();
  bool isLoading = false;

  void showMessage(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> createPassword() async {
    final p1 = passwordController.text.trim();
    final p2 = confirmController.text.trim();
    if (p1.isEmpty || p2.isEmpty) {
      showMessage('من فضلك أدخل وكبّر كلمة السر مرتين');
      return;
    }
    if (p1 != p2) {
      showMessage('كلمتا السر غير متطابقتين');
      return;
    }
    setState(() => isLoading = true);
    try {
      final snap = await Supabase.instance.client
          .from('users')
          .select()
          .eq('code', widget.code)
          .limit(1);

      if (snap.isEmpty) {
        showMessage('الكود غير موجود');
      } else {
        final docId = snap.first['id'];
        await Supabase.instance.client
            .from('users')
            .update({'password': p1})
            .eq('id', docId);
        showMessage('تم إنشاء كلمة السر بنجاح');
        Navigator.pop(context);
      }
    } catch (e) {
      showMessage('حدث خطأ، حاول مرة أخرى');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء كلمة السر')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('الكود: ${widget.code}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة السر الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة السر',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: createPassword,
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }
}
