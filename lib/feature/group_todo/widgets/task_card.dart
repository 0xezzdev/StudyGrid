import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/feature/group_todo/features/group_task_model.dart';
import 'package:study_grid/feature/group_todo/features/task_helpers.dart';
//import 'package:study_grid/feature/group_todo/models/group_task_model.dart';
//import 'package:study_grid/feature/group_todo/helpers/task_helpers.dart';
import 'package:study_grid/feature/group_todo/widgets/task_meta_chip.dart';
import 'package:study_grid/feature/group_todo/widgets/admin_editing.dart';
import 'package:study_grid/feature/group_todo/widgets/card_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskCard extends StatelessWidget {
  final GroupTask task;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.itemsColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.mainTextColor, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: CardText(text: task.title)),
                AdminEditing(
                  onDelete: onDelete,
                  onEdit: () => _showEditSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TaskMetaChip(
                  backgroundColor: getPriorityBgColor(task.priority),
                  icon: Icons.flag,
                  iconColor: getPriorityColor(task.priority),
                  text: getPriorityLabel(task.priority),
                  textColor: getPriorityColor(task.priority),
                ),
                const SizedBox(width: 6),
                TaskMetaChip(
                  backgroundColor: AppColors.dateColor,
                  icon: Icons.calendar_today_outlined,
                  iconColor: const Color(0xFF5A5A8A),
                  text: formatDate(task.dueDate),
                  textColor: const Color(0xFF5A5A8A),
                ),
                const SizedBox(width: 6),
                TaskMetaChip(
                  backgroundColor: AppColors.dateColor,
                  icon: Icons.timer,
                  iconColor: const Color(0xFF5A5A8A),
                  text: getDaysLeft(task.dueDate),
                  textColor: const Color(0xFF5A5A8A),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final titleController = TextEditingController(text: task.title);
    DateTime selectedDate = task.dueDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.itemsColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Task',
                style: TextStyle(
                  color: AppColors.subTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: TextStyle(color: AppColors.subTextColor),
                decoration: InputDecoration(
                  hintText: 'Task title',
                  hintStyle: TextStyle(
                    color: AppColors.subTextColor.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.subTextColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                icon: Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.subTextColor,
                ),
                label: Text(
                  formatDate(selectedDate),
                  style: TextStyle(color: AppColors.subTextColor),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.itemsColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.subTextColor),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    try {
                      await Supabase.instance.client
                          .from('group_todo')
                          .update({
                            'title': titleController.text,
                            'due_date': selectedDate.toIso8601String().split(
                              'T',
                            )[0],
                          })
                          .eq('id', task.id);
                      Navigator.pop(context);
                      onRefresh();
                    } catch (e) {
                      print('Update error: $e');
                    }
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: AppColors.subTextColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
