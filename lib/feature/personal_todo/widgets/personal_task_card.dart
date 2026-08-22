import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/feature/personal_todo/helpers/personal_task_helpers.dart';
import 'package:study_grid/feature/personal_todo/models/personal_task_model.dart';
import 'package:study_grid/feature/personal_todo/widgets/personal_card_text.dart';
import 'package:study_grid/feature/personal_todo/widgets/personal_task_actions.dart'
    show PersonalTaskActions;
import 'package:study_grid/feature/personal_todo/widgets/personal_task_meta_chip.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalTaskCard extends StatefulWidget {
  final PersonalTask task;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const PersonalTaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  State<PersonalTaskCard> createState() => _PersonalTaskCardState();
}

class _PersonalTaskCardState extends State<PersonalTaskCard> {
  bool _isAddingSubtask = false;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final bool isCompleted = task.status == 'done';
    final int doneCount = task.subtasks.where((s) => s.isDone).length;
    final int total = task.subtasks.length;
    // ✅ الأولوية بتتحسب لحظيًا من قرب الميعاد، مش من قيمة مخزنة في الداتابيز
    final String priority = getPriorityFromDueDate(task.dueDate);

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
                // ✅ Circular Checkbox
                GestureDetector(
                  onTap: () => _toggleComplete(context),
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.greenColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.greenColor
                            : AppColors.subTextColor,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),

                // ✅ Title مع خط لو completed
                Expanded(
                  child: CardText(text: task.title, isCompleted: isCompleted),
                ),

                // ✅ Actions menu
                PersonalTaskActions(
                  onDelete: widget.onDelete,
                  onEdit: () => _showEditSheet(context),
                  onViewSubtasks: () {
                    setState(() => _isAddingSubtask = true);
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                TaskMetaChip(
                  backgroundColor: getPriorityBgColor(priority),
                  icon: Icons.flag,
                  iconColor: getPriorityColor(priority),
                  text: getPriorityLabel(priority),
                  textColor: getPriorityColor(priority),
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
                if (total > 0) ...[
                  const SizedBox(width: 6),
                  TaskMetaChip(
                    backgroundColor: AppColors.dateColor,
                    icon: Icons.checklist,
                    iconColor: const Color(0xFF5A5A8A),
                    text: '$doneCount/$total',
                    textColor: const Color(0xFF5A5A8A),
                  ),
                ],
              ],
            ),

            // ✅ قائمة الـ Subtasks تحت الـ meta chips مباشرة
            if (total > 0) ...[
              const SizedBox(height: 10),
              ...task.subtasks.map(
                (subtask) => _SubtaskRow(
                  subtask: subtask,
                  onToggle: () => _toggleSubtask(subtask),
                ),
              ),
            ],

            // ✅ حقل إضافة subtask جديد (قابل للتوسيع)
            if (_isAddingSubtask) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 14, color: AppColors.subTextColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _subtaskController,
                        autofocus: true,
                        style: TextStyle(
                          color: AppColors.mainTextColor,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a subtask...',
                          hintStyle: TextStyle(
                            color: AppColors.subTextColor.withOpacity(0.5),
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (value) => _addSubtask(value),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _isAddingSubtask = false;
                        _subtaskController.clear();
                      }),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _isAddingSubtask = true),
                  child: Text(
                    '+ Add subtask',
                    style: TextStyle(
                      color: AppColors.subTextColor.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ Toggle complete
  Future<void> _toggleComplete(BuildContext context) async {
    try {
      final task = widget.task;
      final bool isCompleted = task.status == 'done';
      await Supabase.instance.client
          .from('personal_todo')
          .update({
            'status': isCompleted ? 'pending' : 'done',
            'completed_at': isCompleted
                ? null
                : DateTime.now().toIso8601String(),
          })
          .eq('id', task.id);
      widget.onRefresh();
    } catch (e) {
      print('Toggle error: $e');
    }
  }

  // ✅ Toggle subtask - مباشرة من الكارت، من غير ما نفتح أي شيت
  // كمان بتشيك: لو كل الـ subtasks بقت done، تخلّص التاسك الأب تلقائيًا.
  // ولو رجعت لغيت subtask بعد ما كانت كلها خلصت، ترجّع التاسك الأب pending.
  // (ده حل client-side مؤقت؛ لو ركّبت الـ DB trigger بعدين، شيل الجزء ده
  // وارجعه لسطرين بس: update للـ subtask + onRefresh)
  Future<void> _toggleSubtask(SubTask subtask) async {
    try {
      final bool newDone = !subtask.isDone;
      await Supabase.instance.client
          .from('sub_tasks')
          .update({'is_done': newDone})
          .eq('id', subtask.id);

      // نحسب هل كل الـ subtasks بقت done بعد التعديل ده
      final task = widget.task;
      final bool allDoneAfterToggle =
          task.subtasks.isNotEmpty &&
          task.subtasks.every((s) => s.id == subtask.id ? newDone : s.isDone);
      final bool taskCurrentlyDone = task.status == 'done';

      if (allDoneAfterToggle && !taskCurrentlyDone) {
        // كل الـ subtasks خلصت والتاسك الأب لسه pending -> نخلّصه تلقائيًا
        await Supabase.instance.client
            .from('personal_todo')
            .update({
              'status': 'done',
              'completed_at': DateTime.now().toIso8601String(),
            })
            .eq('id', task.id);
      } else if (!allDoneAfterToggle && taskCurrentlyDone) {
        // كانت كلها خلصت (وخلّصت التاسك الأب تلقائيًا) وبعدين لغينا واحدة
        // -> نرجّع التاسك الأب pending تاني
        await Supabase.instance.client
            .from('personal_todo')
            .update({'status': 'pending', 'completed_at': null})
            .eq('id', task.id);
      }

      // الـ parent هيعمل fetchTasks() وهيرجّع للكارت ده task جديد بالبيانات المحدثة
      widget.onRefresh();
    } catch (e) {
      print('Toggle subtask error: $e');
    }
  }

  // ✅ إضافة subtask جديد مباشرة من الكارت
  Future<void> _addSubtask(String value) async {
    if (value.trim().isEmpty) return;
    try {
      await Supabase.instance.client.from('sub_tasks').insert({
        'todo_id': widget.task.id,
        'title': value.trim(),
        'is_done': false,
      });
      _subtaskController.clear();
      setState(() => _isAddingSubtask = false);
      widget.onRefresh();
    } catch (e) {
      print('Subtask insert error: $e');
    }
  }

  // ✅ Edit sheet
  void _showEditSheet(BuildContext context) {
    final task = widget.task;
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
                          .from('personal_todo')
                          .update({
                            'title': titleController.text,
                            'due_date': selectedDate.toIso8601String().split(
                              'T',
                            )[0],
                          })
                          .eq('id', task.id);
                      Navigator.pop(context);
                      widget.onRefresh();
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

// صف صغير بيمثل subtask واحد جوه الكارت الأساسي
class _SubtaskRow extends StatelessWidget {
  final SubTask subtask;
  final VoidCallback onToggle;

  const _SubtaskRow({required this.subtask, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(left: 4, right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subtask.isDone
                    ? AppColors.greenColor
                    : Colors.transparent,
                border: Border.all(
                  color: subtask.isDone
                      ? AppColors.greenColor
                      : AppColors.subTextColor,
                  width: 1.5,
                ),
              ),
              child: subtask.isDone
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  color: subtask.isDone
                      ? AppColors.subTextColor
                      : AppColors.mainTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration: subtask.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
