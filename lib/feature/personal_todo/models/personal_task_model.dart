class PersonalTask {
  final int id;
  final String title;
  final String priority;
  final DateTime dueDate;
  final String status;
  final DateTime? reminderAt;
  final DateTime? completedAt;
  final List<SubTask> subtasks;

  PersonalTask({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    required this.status,
    this.reminderAt,
    this.completedAt,
    this.subtasks = const [],
  });

  factory PersonalTask.fromJson(Map<String, dynamic> json) {
    return PersonalTask(
      id: json['id'],
      title: json['title'],
      // ✅ priority بقت محسوبة لحظيًا من dueDate في الواجهة (شوف
      // getPriorityFromDueDate في personal_task_helpers.dart)، فالقيمة
      // المخزنة في الداتابيز (لو موجودة أو null) مبقتش مؤثرة في العرض.
      // بنحطلها fallback هنا بس عشان نتجنب أي crash لو العمود فاضي.
      priority: json['priority'] ?? 'low',
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      reminderAt: json['reminder_at'] != null
          ? DateTime.parse(json['reminder_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      subtasks: json['sub_tasks'] != null
          ? (json['sub_tasks'] as List).map((e) => SubTask.fromJson(e)).toList()
          : [],
    );
  }
}

class SubTask {
  final int id;
  final int todoId;
  final String title;
  final bool isDone;

  SubTask({
    required this.id,
    required this.todoId,
    required this.title,
    required this.isDone,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      todoId: json['todo_id'],
      title: json['title'],
      isDone: json['is_done'] ?? false,
    );
  }
}
