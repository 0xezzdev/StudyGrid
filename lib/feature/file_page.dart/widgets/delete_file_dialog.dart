import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import '../../../core/models/class_file.dart';

class DeleteFileDialog extends StatelessWidget {
  const DeleteFileDialog({super.key, required this.file, required this.onConfirm});

  final ClassFile file;
  final VoidCallback onConfirm;

  static Future<void> show(
    BuildContext context, {
    required ClassFile file,
    required VoidCallback onConfirm,
  }) =>
      showDialog(
        context: context,
        builder: (_) => DeleteFileDialog(file: file, onConfirm: onConfirm),
      );

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete File',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${file.name}"?',
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Delete',
              style: TextStyle(
                  color: AppColors.redColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
}