import 'package:study_grid/feature/personal_todo/models/personal_task_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalTodoRepository {
  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<List<PersonalTask>> fetchTasks() async {
    if (_userId == null) return [];
    final response = await _supabase
        .from('personal_todo')
        .select('*, sub_tasks(*)')
        .eq('user_id', _userId!)
        .order('due_date', ascending: true);
    return (response as List).map((e) => PersonalTask.fromJson(e)).toList();
  }

  Future<void> addTask({
    required String title,
    required DateTime dueDate,
    DateTime? reminderAt,
    List<String> subtaskTitles = const [],
  }) async {
    if (_userId == null) return;
    final response = await _supabase
        .from('personal_todo')
        .insert({
          'user_id': _userId,
          'title': title,
          'due_date': dueDate.toIso8601String().split('T')[0],
          'status': 'pending',
          'reminder_at': reminderAt?.toIso8601String(),
        })
        .select()
        .single();

    if (subtaskTitles.isNotEmpty) {
      final int taskId = response['id'];
      await _supabase
          .from('sub_tasks')
          .insert(
            subtaskTitles
                .map((t) => {'todo_id': taskId, 'title': t, 'is_done': false})
                .toList(),
          );
    }
  }

  Future<void> updateTask({
    required int taskId,
    required String title,
    required DateTime dueDate,
  }) async {
    await _supabase
        .from('personal_todo')
        .update({
          'title': title,
          'due_date': dueDate.toIso8601String().split('T')[0],
        })
        .eq('id', taskId);
  }

  Future<void> deleteTask(int taskId) async {
    await _supabase.from('personal_todo').delete().eq('id', taskId);
  }

  Future<void> toggleTaskComplete({
    required int taskId,
    required bool isCurrentlyDone,
  }) async {
    await _supabase
        .from('personal_todo')
        .update({
          'status': isCurrentlyDone ? 'pending' : 'done',
          'completed_at': isCurrentlyDone
              ? null
              : DateTime.now().toIso8601String(),
        })
        .eq('id', taskId);
  }

  Future<void> toggleSubtask({
    required int subtaskId,
    required bool isCurrentlyDone,
  }) async {
    await _supabase
        .from('sub_tasks')
        .update({'is_done': !isCurrentlyDone})
        .eq('id', subtaskId);
  }

  Future<void> addSubtask({required int taskId, required String title}) async {
    await _supabase.from('sub_tasks').insert({
      'todo_id': taskId,
      'title': title,
      'is_done': false,
    });
  }

  RealtimeChannel subscribeToChanges(void Function() onChanged) {
    return _supabase
        .channel('personal_todo_${_userId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'personal_todo',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _userId ?? '',
          ),
          callback: (_) => onChanged(),
        )
        .subscribe();
  }
}
