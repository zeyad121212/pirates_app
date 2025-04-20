import 'package:flutter/material.dart';

class DevelopmentManagerScreen extends StatelessWidget {
  const DevelopmentManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("مسؤول ملف التنمية"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // متابعة التطور التدريبي
              },
              child: Text('متابعة التطور التدريبي'),
            ),
            ElevatedButton(
              onPressed: () {
                // جمع البيانات من المحافظات
              },
              child: Text('جمع البيانات من المحافظات'),
            ),
          ],
        ),
      ),
    );
  }
}
