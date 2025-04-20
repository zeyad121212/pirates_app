import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String role;

  const PlaceholderScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("مرحبا بك! دورك هو $role", style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
