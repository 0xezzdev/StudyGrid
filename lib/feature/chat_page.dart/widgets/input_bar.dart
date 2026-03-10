import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/feature/chat_page.dart/widgets/send_button.dart';




class InputBar extends StatelessWidget {
  const InputBar({
    super.key,
    required this.textController,
    required this.showAttachMenu,
    required this.onSend,
  
  });

  final TextEditingController textController;
  final bool showAttachMenu;
  final VoidCallback onSend;
  

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField()),
                  const SizedBox(width: 8),
                  SendButton(onTap: onSend),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildTextField() => Container(
        decoration: BoxDecoration(
          color: AppColors.itemsColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Type a message...',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => onSend(),
        ),
      );

  
}