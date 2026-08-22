import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/feature/personal_todo/helpers/personal_task_helpers.dart';
import 'package:study_grid/feature/personal_todo/repository/personal_todo_repository.dart';
import 'package:study_grid/feature/personal_todo/widgets/personal_task_cards.dart'; // ✅ ده الناقص

class PersonalToDo extends StatefulWidget {
  const PersonalToDo({super.key});

  @override
  State<PersonalToDo> createState() => _PersonalToDoState();
}

class _PersonalToDoState extends State<PersonalToDo> {
  final GlobalKey<PersonalTaskCardsState> _taskCardsKey =
      GlobalKey<PersonalTaskCardsState>();
  final _repo = PersonalTodoRepository();

  void _showAddSheet(BuildContext context) {
    final titleController = TextEditingController();
    DateTime? selectedDate;
    DateTime? reminderAt;
    final List<String> subtaskTitles = [];
    final subtaskController = TextEditingController();
    bool showSubtasks = false;
    bool showReminder = false;

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

              // Title
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

              // Due Date
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null)
                    setModalState(() => selectedDate = picked);
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

              // Add Subtasks
              TextButton.icon(
                onPressed: () =>
                    setModalState(() => showSubtasks = !showSubtasks),
                icon: Icon(
                  showSubtasks ? Icons.expand_less : Icons.add,
                  color: AppColors.subTextColor,
                ),
                label: Text(
                  'Add Subtasks',
                  style: TextStyle(color: AppColors.subTextColor),
                ),
              ),

              if (showSubtasks) ...[
                ...subtaskTitles.map(
                  (title) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.subTextColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: AppColors.mainTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setModalState(() => subtaskTitles.remove(title)),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextField(
                  controller: subtaskController,
                  style: TextStyle(color: AppColors.subTextColor, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Add a subtask...',
                    hintStyle: TextStyle(
                      color: AppColors.subTextColor.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add, color: AppColors.subTextColor),
                      onPressed: () {
                        if (subtaskController.text.isNotEmpty) {
                          setModalState(() {
                            subtaskTitles.add(subtaskController.text);
                            subtaskController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setModalState(() {
                        subtaskTitles.add(value);
                        subtaskController.clear();
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],

              // Set Reminder
              TextButton.icon(
                onPressed: () async {
                  if (showReminder) {
                    setModalState(() {
                      reminderAt = null;
                      showReminder = false;
                    });
                    return;
                  }
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setModalState(() {
                        reminderAt = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          time.hour,
                          time.minute,
                        );
                        showReminder = true;
                      });
                    }
                  }
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: reminderAt != null
                      ? AppColors.greenColor
                      : AppColors.subTextColor,
                ),
                label: Text(
                  reminderAt != null
                      ? '${formatDate(reminderAt!)} ${reminderAt!.hour}:${reminderAt!.minute.toString().padLeft(2, '0')}'
                      : 'Set Reminder',
                  style: TextStyle(
                    color: reminderAt != null
                        ? AppColors.greenColor
                        : AppColors.subTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Add Task button
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

                    // ✅ لو فيه نص متكتوب في حقل الـ subtask ولسه محضغطش
                    // + أو Enter، نضيفه تلقائيًا للقايمة قبل الحفظ عشان
                    // مايضعش لو المستخدم دوس "Add Task" على طول.
                    final List<String> finalSubtaskTitles = List<String>.from(
                      subtaskTitles,
                    );
                    final String pendingSubtask = subtaskController.text.trim();
                    if (pendingSubtask.isNotEmpty) {
                      finalSubtaskTitles.add(pendingSubtask);
                    }

                    try {
                      await _repo.addTask(
                        title: titleController.text,
                        dueDate: selectedDate!,
                        reminderAt: reminderAt,
                        subtaskTitles: finalSubtaskTitles,
                      );
                      Navigator.pop(context);
                      _taskCardsKey.currentState?.fetchTasks();
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
              Expanded(child: PersonalTaskCards(key: _taskCardsKey)),
            ],
          ),
        ),
      ),
    );
  }
}
