import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import '../../../core/models/class_file.dart';

class FileCard extends StatelessWidget {
  const FileCard({
    super.key,
    required this.file,
    required this.formattedTime,
    required this.isAdmin,
    required this.onDownload,
    this.onDelete,
  });

  final ClassFile file;
  final String formattedTime;
  final bool isAdmin;
  final VoidCallback onDownload;
  final VoidCallback? onDelete;

  static ({Color color, IconData icon}) _typeStyle(String type) =>
      switch (type) {
        'pdf'         => (color: AppColors.sentMessageMainColor, icon: Icons.picture_as_pdf_rounded),
        'doc'||'docx' => (color: AppColors.cyanColor, icon: Icons.description_rounded),
        _             => (color: AppColors.greenColor, icon: Icons.insert_drive_file_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final style = _typeStyle(file.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          _FileIcon(color: style.color, icon: style.icon),
          const SizedBox(width: 12),
          Expanded(child: _FileMeta(file: file, formattedTime: formattedTime)),
          // Download — always visible
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white38, size: 20),
            onPressed: onDownload,
          ),
          // Delete — only for admin
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFFF6B6B), size: 20),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  const _FileIcon({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 46, height: 46,
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3), width: 1.5),
    ),
    child: Icon(icon, color: color, size: 22),
  );
}

class _FileMeta extends StatelessWidget {
  const _FileMeta({required this.file, required this.formattedTime});
  final ClassFile file;
  final String formattedTime;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(file.name,
          style: const TextStyle(color: Colors.white, fontSize: 13,
              fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 4),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          Text('${file.sizeMB.toStringAsFixed(1)} MB',
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const Text(' · ', style: TextStyle(color: Colors.white24, fontSize: 11)),
          Text(file.uploaderName,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const Text(' · ', style: TextStyle(color: Colors.white24, fontSize: 11)),
          Text(formattedTime,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ]),
      ),
    ],
  );
}