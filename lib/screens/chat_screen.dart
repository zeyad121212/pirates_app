import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/supabase_service.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final _supabaseService = SupabaseService();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => isLoading = true);
    try {
      final sentMessages = await _supabaseService.getMessages(widget.currentUserId);
      final receivedMessages = await _supabaseService.getReceivedMessages(widget.currentUserId).first;
      
      final List<ChatMessage> allMessages = [];
      
      for (final Map<String, dynamic> message in sentMessages) {
        allMessages.add(ChatMessage.fromJson(message));
      }
      
      for (final Map<String, dynamic> message in receivedMessages) {
        allMessages.add(ChatMessage.fromJson(message));
      }
      
      allMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      setState(() {
        messages.clear();
        messages.addAll(allMessages);
        isLoading = false;
      });

      // Mark messages as read
      _markMessagesAsRead();
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to load messages');
    }
  }

  void _subscribeToMessages() {
    _supabaseService.subscribeToMessages(widget.currentUserId).listen((List<Map<String, dynamic>> event) {
      final List<ChatMessage> newMessages = [];
      for (final Map<String, dynamic> message in event) {
        newMessages.add(ChatMessage.fromJson(message));
      }
      
      final List<ChatMessage> updatedMessages = List<ChatMessage>.from(messages);
      updatedMessages.addAll(newMessages);
      updatedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      setState(() {
        messages.clear();
        messages.addAll(updatedMessages);
      });
      _markMessagesAsRead();
    });
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await _supabaseService.markMessagesAsRead(
        receiverId: widget.currentUserId,
        senderId: widget.otherUserId,
      );
    } catch (e) {
      // Silently handle error
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    try {
      await _supabaseService.sendMessage(
        widget.currentUserId,
        widget.otherUserId,
        content,
      );
      _scrollToBottom();
    } catch (e) {
      _showError('Failed to send message');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == widget.currentUserId;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
