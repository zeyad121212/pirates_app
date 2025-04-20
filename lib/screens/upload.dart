import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'dart:typed_data';

Future<void> uploadUsersDataFromExcel() async {
  // تحميل ملف Excel من التطبيق (افتراض أن الملف داخل مجلد assets)
  final ByteData data = await rootBundle.rootBundle.load('assets/your_file.xlsx');
  final buffer = data.buffer.asUint8List();

  // قراءة البيانات من ملف Excel
  var excel = Excel.decodeBytes(buffer);

  // الحصول على الورقة الأولى
  var sheet = excel.tables.keys.first;
  var rows = excel.tables[sheet]?.rows;

  if (rows == null) {
    print("No rows found in the Excel file.");
    return;
  }

  // البيانات التي سيتم رفعها على Firestore
  final firestore = FirebaseFirestore.instance;

  // تخطي الصف الأول لأنه يحتوي على العناوين
  for (int i = 1; i < rows.length; i++) {
    var row = rows[i];

    // التأكد من أن الصف يحتوي على البيانات المطلوبة
    if (row.length >= 4) {
      String code = row[0]?.toString() ?? '';
      String name = row[1]?.toString() ?? '';
      String role = row[2]?.toString() ?? '';
      String password = row[3]?.toString() ?? '';

      // رفع البيانات إلى Firestore
      await firestore.collection('users').add({
        'code': code,
        'name': name,
        'role': role,
        'password': password,
      });
    }
  }

  print("تم رفع البيانات بنجاح من ملف Excel!");
}
