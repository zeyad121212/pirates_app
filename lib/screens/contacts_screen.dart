import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  final String currentUserId;
  final String userRole;
  const ContactsScreen({
    super.key,
    required this.currentUserId,
    required this.userRole,
  });

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> contacts = [];
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      // Debug: log inputs
      debugPrint('ContactsScreen: loading contacts for userId=${widget.currentUserId}, role=${widget.userRole}');
      final data = await _supabaseService.getContactsByRole(
        widget.currentUserId,
        widget.userRole,
      );
      // Debug: log result
      debugPrint('ContactsScreen: loaded contacts: $data');
      setState(() {
        contacts = data;
        isLoading = false;
      });
    } catch (e, st) {
      setState(() => isLoading = false);
      // Debug: log error details
      debugPrint('ContactsScreen: error loading contacts: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load contacts: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    title: Text(contact['name'] ?? ''),
                    subtitle: Text(contact['role'] ?? ''),
                    trailing:
                        contact['unread_count'] != null &&
                                contact['unread_count'] > 0
                            ? CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Text(
                                '${contact['unread_count']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )
                            : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                currentUserId: widget.currentUserId,
                                otherUserId: contact['id'],
                                otherUserName: contact['name'] ?? '',
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
