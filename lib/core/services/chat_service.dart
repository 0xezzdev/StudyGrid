import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';

class ChatService {
  final _client = Supabase.instance.client;

  String get currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      debugPrint(' WARNING: No logged in user!');
      return '';
    }
    debugPrint(' currentUserId: $id');
    return id;
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────


  Future<List<ChatMessage>> fetchMessages(int groupId) async {
    try {
      final res = await _client
          .from('group_messages')
          .select('id, content, created_at, sender_id, users!fk_group_messages_sender(id, name, avatar_url)')
          .eq('group_id', groupId)
          .order('created_at', ascending: true);

      return (res as List)
          .map((row) => ChatMessage.fromSupabase(row, currentUserId))
          .toList();
    } catch (e) {
      debugPrint(' fetchMessages error: $e');
      return [];
    }
  }

  // ── Send ──────────────────────────────────────────────────────────────────
  Future<void> sendMessage(int groupId, String content) async {
    try {
      await _client.from('group_messages').insert({
        'group_id':  groupId,
        'sender_id': currentUserId,
        'content':   content,
      });
      debugPrint(' Message sent');
    } catch (e) {
      debugPrint('sendMessage error: $e');
    }
  }

  // ── Poll every 2 seconds instead of Realtime ──────────────────────────────
  Stream<List<ChatMessage>> messagesStream(int groupId) async* {
    while (true) {
      yield await fetchMessages(groupId);
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}