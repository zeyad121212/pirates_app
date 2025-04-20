import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'contacts_screen.dart';
import 'training_requests_screen.dart';
import 'code_entry_screen.dart';

class ProjectManagerScreen extends StatelessWidget {
  final String currentUserId;
  final String userRole;

  const ProjectManagerScreen({
    super.key,
    required this.currentUserId,
    required this.userRole,
  });

  Future<void> uploadUsersDataFromExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      var fileBytes = result.files.single.bytes;

      if (fileBytes != null) {
        var excel = Excel.decodeBytes(fileBytes);
        var sheet = excel.tables.keys.first;
        var rows = excel.tables[sheet]?.rows;

        if (rows == null) {
          print("No rows found in the Excel file.");
          return;
        }

        final supabase = Supabase.instance.client;

        for (int i = 1; i < rows.length; i++) {
          var row = rows[i];
          if (row.length >= 4) {
            // trim values to avoid leading/trailing whitespace
            String code = (row[0]?.toString() ?? '').trim();
            String name = (row[1]?.toString() ?? '').trim();
            String role = (row[2]?.toString() ?? '').trim();
            String password = (row[3]?.toString() ?? '').trim();

            final response =
                await supabase.from('users').insert([
                  {
                    'code': code,
                    'name': name,
                    'role': role,
                    'password': password,
                  },
                ]);

            if (response.count == null) {
              print('Error inserting user');
            } else {
              print("تم رفع البيانات بنجاح من ملف Excel!");
            }
          }
        }
      } else {
        print("لم يتم اختيار ملف.");
      }
    } else {
      print("لم يتم اختيار ملف.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدير المشروع'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => CodeEntryScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: uploadUsersDataFromExcel,
              child: const Text("رفع البيانات من Excel"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrainingRequestsScreen(
                      currentUserId: currentUserId,
                      userRole: userRole,
                    ),
                  ),
                );
              },
              child: const Text('متابعة الطلب'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ContactsScreen(
                          currentUserId: currentUserId,
                          userRole: userRole,
                        ),
                  ),
                );
              },
              child: const Text('المحادثات'),
            ),
          ],
        ),
      ),
    );
  }
}
