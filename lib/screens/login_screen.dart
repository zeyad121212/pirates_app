import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pirates_app/screens/projectmanagerscreen.dart';
import 'package:pirates_app/screens/trainerscreen.dart';
import 'package:pirates_app/screens/mentorscreen.dart';

class LoginScreen extends StatefulWidget {
  final String code;
  const LoginScreen({super.key, required this.code});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> verifyPassword() async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      showMessage("من فضلك أدخل كلمة السر");
      return;
    }

    setState(() => isLoading = true);

    try {
      // fetch a single user matching code and password
      final userData = await Supabase.instance.client
          .from('users')
          .select()
          .eq('code', widget.code)
          .eq('password', password)
          .maybeSingle();

      setState(() => isLoading = false);

      if (userData == null) {
        showMessage("الكود أو كلمة السر غير صحيحة");
        return;
      }

      final name = userData['name'] ?? '';
      final role = userData['role'] ?? '';
      final currentUserId = userData['id']?.toString() ?? '';

      showMessage("أهلاً $name! دورك هو $role");

      if (role == 'PM') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectManagerScreen(
              currentUserId: currentUserId,
              userRole: role,
            ),
          ),
        );
      } else if (role == 'MN') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TrainerScreen(
              currentUserId: currentUserId,
              userRole: role,
            ),
          ),
        );
      } else if (role == 'MB') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MentorScreen(
              currentUserId: currentUserId,
              userRole: role,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      showMessage("حدث خطأ أثناء التحقق من كلمة السر");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "كلمة السر"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: verifyPassword,
                  child: const Text("تسجيل الدخول"),
                ),
          ],
        ),
      ),
    );
  }
}
