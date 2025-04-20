import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;

  const ChatListScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> contacts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => isLoading = true);
    try {
      // Get contacts based on user role
      final userContacts = await _supabaseService.getContactsByRole(
        widget.currentUserId,
        widget.currentUserRole,
      );
      setState(() {
        contacts = userContacts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to load contacts');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openChat(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          currentUserId: widget.currentUserId,
          otherUserId: userId,
          otherUserName: userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
              ? const Center(
                  child: Text('No contacts available'),
                )
              : ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final hasUnread = contact['unread_count'] > 0;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(contact['name'][0].toUpperCase()),
                      ),
                      title: Text(contact['name']),
                      subtitle: Text(contact['role']),
                      trailing: hasUnread
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                contact['unread_count'].toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          : null,
                      onTap: () => _openChat(
                        contact['id'],
                        contact['name'],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadContacts,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
