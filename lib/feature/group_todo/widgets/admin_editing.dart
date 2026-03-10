import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class AdminEditing extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AdminEditing({super.key, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.backgroundColor,
      icon: Icon(Icons.more_vert, color: AppColors.subTextColor),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: AppColors.subTextColor))),
        PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.subTextColor))),
      ],
      onSelected: (String value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
    );
  }
}
