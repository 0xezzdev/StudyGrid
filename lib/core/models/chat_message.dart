import 'package:flutter/material.dart';

enum MessageType { text, image }

class ChatMessage {
  final String id;
  final String senderName;
  final String senderInitials;
  final Color avatarColor;
  final String? text;
  final String? imagePath;
  final String? avatarUrl;
  final MessageType type;
  final DateTime time;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderInitials,
    required this.avatarColor,
    this.text,
    this.imagePath,
    this.avatarUrl,
    required this.type,
    required this.time,
    required this.isMe,
  });

  factory ChatMessage.fromSupabase(Map<String, dynamic> row, String currentUserId) {
    final sender   = row['users'] as Map<String, dynamic>?;
    final isMe     = row['sender_id'] == currentUserId;
    final name     = sender?['name'] ?? 'Unknown';
    final avatarUrl = sender?['avatar_url'];
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    debugPrint('avatarUrl for $name: $avatarUrl');

    return ChatMessage(
      id:             row['id'].toString(),
      senderName:     name,
      senderInitials: initials,
      avatarUrl:      avatarUrl,
      avatarColor:    isMe
          ? const Color(0xFF7C4DFF)
          : const Color(0xFF5C6BC0),
      text:           row['content'],
      type:           MessageType.text,
      time:           DateTime.parse(row['created_at']),
      isMe:           isMe,
    );
  }
  factory ChatMessage.fromSupabaseWithName(
      Map<String, dynamic> row,
      String senderId,
      String name,
      String currentUserId,
      ) {
    final isMe = senderId == currentUserId;
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();

    return ChatMessage(
      id: row['id'].toString(),
      senderName: name,
      senderInitials: initials,
      avatarColor: isMe
          ? const Color(0xFF7C4DFF)
          : const Color(0xFF5C6BC0),
      text: row['content'],
      type: MessageType.text,
      time: DateTime.parse(row['created_at']),
      isMe: isMe,
    );
  }
}
