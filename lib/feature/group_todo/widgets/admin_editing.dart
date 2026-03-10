import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class AdminEditing extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AdminEditing({super.key, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.subTextColor),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (String value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
    );
  }
}
