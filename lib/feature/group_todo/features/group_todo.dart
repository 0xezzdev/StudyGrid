import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/feature/group_todo/features/task_helpers.dart';
import 'package:study_grid/feature/group_todo/widgets/task_cards.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupToDo extends StatelessWidget {
  final int groupId;
  const GroupToDo({super.key, required this.groupId});

  void _showAddSheet(BuildContext context) {
    final titleController = TextEditingController();
    DateTime? selectedDate;

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
                'Add New Task',
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
                    initialDate: DateTime.now().add(Duration(days: 1)),
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
                  selectedDate == null
                      ? 'Select Due Date'
                      : formatDate(selectedDate!),
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
                    if (titleController.text.isEmpty || selectedDate == null)
                      return;
                    try {
                      await Supabase.instance.client.from('group_todo').insert({
                        'group_id': groupId,
                        'title': titleController.text,
                        'due_date': selectedDate!.toIso8601String().split(
                          'T',
                        )[0],
                        'status': 'pending',
                        'created_by':
                            Supabase.instance.client.auth.currentUser!.id,
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      print('Error inserting task: $e');
                    }
                  },
                  child: Text(
                    'Add Task',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              // Add new task button
              GestureDetector(
                onTap: () => _showAddSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.itemsColor,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: AppColors.subTextColor,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: AppColors.subTextColor, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        'Add new task',
                        style: TextStyle(
                          color: AppColors.subTextColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Tasks list
              Expanded(child: TaskCards(groupId: groupId)),
            ],
          ),
        ),
      ),
    );
  }
}
