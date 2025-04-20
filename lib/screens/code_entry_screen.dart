import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_role.dart';
import 'create_password_screen.dart';
import 'projectmanagerscreen.dart';
import 'trainer_dashboard_screen.dart';
import 'supervisor_screen.dart';
import 'coordinator_screen.dart';
import 'provincemanager.dart';
import 'monitoring_agent_screen.dart';
import 'monitoring_agent_dashboard_screen.dart';
import 'dv_completion_screen.dart';

class CodeEntryScreen extends StatefulWidget {
  const CodeEntryScreen({super.key});

  @override
  State<CodeEntryScreen> createState() => _CodeEntryScreenState();
}

class _CodeEntryScreenState extends State<CodeEntryScreen> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> checkCode() async {
    final code = codeController.text.trim();
    if (code.isEmpty) {
      showMessage('من فضلك أدخل الكود');
      return;
    }

    setState(() => isLoading = true);
    try {
      final data = await SupabaseService().getUserByCode(code);
      setState(() => isLoading = false);

      if (data == null) {
        showMessage('Invalid code');
        return;
      }

      final hasPassword =
          data['password'] != null && (data['password'] as String).isNotEmpty;
      if (!hasPassword) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CreatePasswordScreen(code: code)),
        );
        return;
      }

      debugPrint(
        'CodeEntryScreen: role="${data['role']}", code="${data['code']}"',
      );
      // Determine userRole by code prefix first, then by role displayName
      String rawCode = data['code']?.toString() ?? '';
      String codePrefix = rawCode.length >= 2 ? rawCode.substring(0, 2) : '';
      UserRole? userRole = UserRole.fromCode(codePrefix) ?? UserRole.fromCode(data['role']);

      debugPrint('Resolved UserRole: $userRole');

      if (userRole == null) {
        showMessage('Invalid user role: "${data['role']}"');
        return;
      }

      final int userIdInt = data['id'] as int;
      Widget screenWidget;
      switch (userRole) {
        case UserRole.projectManager:
          screenWidget = ProjectManagerScreen(
            currentUserId: userIdInt.toString(),
            userRole: userRole.code,
          );
          break;
        case UserRole.trainer:
          screenWidget = TrainerDashboardScreen(
            currentUserId: userIdInt,
          );
          break;
        case UserRole.monitoringAgent:
          screenWidget = MonitoringAgentDashboardScreen(
            currentUserId: userIdInt,
          );
          break;
        case UserRole.centralCoordinator:
          screenWidget = CoordinatorScreen(
            currentUserId: userIdInt.toString(),
            userRole: userRole.code,
          );
          break;
        case UserRole.supervisor:
          screenWidget = SupervisorScreen(
            currentUserId: userIdInt.toString(),
            userRole: userRole.code,
          );
          break;
        case UserRole.developmentOfficer:
          screenWidget = DvCompletionScreen(
            currentUserId: userIdInt,
          );
          break;
        case UserRole.provinceManager:
          screenWidget = ProvinceManagerScreen(
            currentUserId: userIdInt.toString(),
            userRole: userRole.code,
          );
          break;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screenWidget),
      );
    } catch (e) {
      setState(() => isLoading = false);
      showMessage('حدث خطأ، حاول مرة أخرى');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أدخل الكود')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'كود المستخدم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: checkCode,
                  child: const Text('التالي'),
                ),
          ],
        ),
      ),
    );
  }
}
