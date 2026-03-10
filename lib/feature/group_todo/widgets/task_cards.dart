import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/feature/group_todo/features/group_task_model.dart';
import 'package:study_grid/feature/group_todo/widgets/task_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskCards extends StatefulWidget {
  final int groupId;
  const TaskCards({super.key, required this.groupId});

  @override
  State<TaskCards> createState() => _TaskCardsState();
}

class _TaskCardsState extends State<TaskCards> {
  final _supabase = Supabase.instance.client;
  List<GroupTask> _allTasks = [];
  bool _isLoading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await _supabase
          .from('group_todo')
          .select()
          .eq('group_id', widget.groupId)
          .order('due_date', ascending: true);

      setState(() {
        _allTasks = (response as List)
            .map((e) => GroupTask.fromJson(e))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _subscribeRealtime() {
    _channel = _supabase
        .channel('group_todo_${widget.groupId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_todo',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: widget.groupId,
          ),
          callback: (payload) => _fetchTasks(),
        )
        .subscribe();
  }

  Future<void> _deleteTask(int taskId) async {
    await _supabase.from('group_todo').delete().eq('id', taskId);
    _fetchTasks(); // ← ضيف دي
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.subTextColor),
      );
    }

    final pendingTasks = _allTasks.where((t) => t.status == 'pending').toList();
    final endedTasks = _allTasks.where((t) => t.status == 'done').toList();

    return ListView(
      padding: const EdgeInsets.only(top: 10),
      children: [
        if (pendingTasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'UPCOMING',
              style: TextStyle(
                color: AppColors.subTextColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
        ...pendingTasks.map(
          (task) => TaskCard(
            task: task,
            onDelete: () => _deleteTask(task.id),
            onRefresh: _fetchTasks,
          ),
        ),
        if (endedTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'ENDED',
              style: TextStyle(
                color: AppColors.subTextColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
          ...endedTasks.map(
            (task) => Opacity(
              opacity: 0.5,
              child: TaskCard(
                task: task,
                onDelete: () => _deleteTask(task.id),

                onRefresh: _fetchTasks,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
