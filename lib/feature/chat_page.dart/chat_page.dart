import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/feature/chat_page.dart/widgets/input_bar.dart';
import 'package:study_grid/feature/chat_page.dart/widgets/message_bubble.dart';
import '../../core/models/chat_message.dart';
import '../../core/services/chat_service.dart';



class ChatPage extends StatefulWidget {
  final int groupId;
  final String groupName;

  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController   = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService      = ChatService();
  final _messages         = <ChatMessage>[];
  StreamSubscription?     _sub;
  bool _isLoading         = true;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Stream ────────────────────────────────────────────────────────────────

  void _startStream() {
    _sub = _chatService.messagesStream(widget.groupId).listen((msgs) {
      if (!mounted) return;
      final wasAtBottom = _isNearBottom();
      setState(() {
        _messages..clear()..addAll(msgs);
        _isLoading = false;
      });
      if (wasAtBottom || _messages.length <= msgs.length) _scrollToBottom();
    });
  }

  // ── Send ──────────────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    await _chatService.sendMessage(widget.groupId, text);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    final pos = _scrollController.position;
    return pos.maxScrollExtent - pos.pixels < 100;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _showSenderFor(int i) =>
      i == 0 || _messages[i - 1].senderName != _messages[i].senderName;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: _buildAppBar(),
    body: Column(
      children: [
        Expanded(child: _buildBody()),
        InputBar(
          textController: _textController,
          showAttachMenu: false,
          onSend: _sendMessage,
        ),
      ],
    ),
  );

  AppBar _buildAppBar() => AppBar(
    backgroundColor: AppColors.itemsColor,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white70),
      onPressed: () => Navigator.pop(context),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.groupName.isEmpty ? 'Group Chat' : widget.groupName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Text(
          'Group Chat',
          style: TextStyle(fontSize: 11, color: Colors.white38),
        ),
      ],
    ),
  );

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet.\nSay hello! ',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (_, i) => MessageBubble(
        message: _messages[i],
        showSender: _showSenderFor(i),
      ),
    );
  }
}