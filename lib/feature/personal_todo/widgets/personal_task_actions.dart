import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class PersonalTaskActions extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onViewSubtasks;

  const PersonalTaskActions({
    super.key,
    required this.onDelete,
    required this.onEdit,
    required this.onViewSubtasks,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.subTextColor),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(
          value: 'subtasks',
          child: Text('Subtasks'),
        ), // ➕ ضيف السطر ده
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (String value) {
        if (value == 'edit') onEdit();
        if (value == 'subtasks') onViewSubtasks(); // ➕ وده كمان
        if (value == 'delete') onDelete();
      },
    );
  }
}
