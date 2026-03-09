import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import '../../../core/models/chat_message.dart';



class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.showSender,
  });

  final ChatMessage message;
  final bool showSender;

  @override
  Widget build(BuildContext context) =>
      message.isMe ? _buildMyBubble() : _buildOtherBubble();

  Widget _buildMyBubble() => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 60),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.sentMessageSubColor,
            borderRadius: const BorderRadius.only(
              topLeft:     Radius.circular(18),
              topRight:    Radius.circular(4),
              bottomLeft:  Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.sentMessageSubColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: message.type == MessageType.image
              ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(message.imagePath!),
              width: 200,
              fit: BoxFit.cover,
            ),
          )
              : Text(
            message.text!,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ),
        const SizedBox(height: 4),
        _TimeStamp(time: message.time),
      ],
    ),
  );

  Widget _buildOtherBubble() => Padding(
    padding: const EdgeInsets.only(bottom: 8, right: 60),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showSender
            ? _Avatar(message: message)
            : const SizedBox(width: 32),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSender) ...[
                Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: message.avatarColor,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.receivedMessageMainColor,
                  borderRadius: const BorderRadius.only(
                    topLeft:     Radius.circular(4),
                    topRight:    Radius.circular(18),
                    bottomLeft:  Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.05)),
                ),
                child: Text(
                  message.text ?? '',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.4),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Avatar: photo if available, else first letter ─────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final url = message.avatarUrl;
    final initial = message.senderName.isNotEmpty
        ? message.senderName[0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 16,
      backgroundColor: message.avatarColor,
      child: url != null && url.isNotEmpty
          ? ClipOval(
        child: Image.network(
          url,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initial(initial),
          loadingBuilder: (_, child, loading) =>
          loading == null ? child : _initial(initial),
        ),
      )
          : _initial(initial),
    );
  }

  Widget _initial(String letter) => Text(
    letter,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  );
}

// ── Timestamp ─────────────────────────────────────────────────────────────────

class _TimeStamp extends StatelessWidget {
  const _TimeStamp({required this.time});
  final DateTime time;

  @override
  Widget build(BuildContext context) => Text(
    DateFormat('h:mm a').format(time),
    style: const TextStyle(color: Colors.white30, fontSize: 10),
  );
}