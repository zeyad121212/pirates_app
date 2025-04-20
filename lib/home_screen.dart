// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'province_request_screen.dart';

class HomeScreen extends StatelessWidget {
  final String role;
  final String name;

  const HomeScreen({
    super.key,
    required this.role,
    required this.name,
  });

  // هنا بنحدد بنود القائمة الجانبية حسب الدور
  List<Widget> _buildDrawerItems(BuildContext context) {
    switch (role) {
      case 'PM':
        return [
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('إحصائيات'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('إدارة المدربين'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.request_page),
            title: Text('طلبات المحافظات'),
            onTap: () => Navigator.pop(context),
          ),
        ];
      case 'TR':
        return [
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text('جدولي'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('نقاط التخصص'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('الإشعارات'),
            onTap: () => Navigator.pop(context),
          ),
        ];
      case 'PR':
        return [
          ListTile(
            leading: Icon(Icons.request_page),
            title: Text('طلبات المحافظة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProvinceRequestScreen()),
              );
            },
          ),
        ];
    // أضف حالات Roles أخرى مثل MN, MB, PR, DV حسب حاجتك
      default:
        return [
          ListTile(
            leading: Icon(Icons.home),
            title: Text('الرئيسية'),
            onTap: () => Navigator.pop(context),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مرحبًا $name'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ..._buildDrawerItems(context),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'هذه واجهة $role',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
