import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/feature/personal_todo/models/personal_task_model.dart';
import 'package:study_grid/feature/personal_todo/repository/personal_todo_repository.dart';
import 'package:study_grid/feature/personal_todo/widgets/personal_task_card.dart';

class PersonalTaskCards extends StatefulWidget {
  const PersonalTaskCards({super.key});

  @override
  State<PersonalTaskCards> createState() => PersonalTaskCardsState();
}

class PersonalTaskCardsState extends State<PersonalTaskCards> {
  final _repo = PersonalTodoRepository();
  List<PersonalTask> _allTasks = [];
  bool _isLoading = true;
  dynamic _channel;

  @override
  void initState() {
    super.initState();
    fetchTasks();
    _channel = _repo.subscribeToChanges(fetchTasks);
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> fetchTasks() async {
    try {
      final tasks = await _repo.fetchTasks();
      setState(() {
        _allTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Fetch error: $e');
    }
  }

  Future<void> _deleteTask(int taskId) async {
    await _repo.deleteTask(taskId);
    fetchTasks();
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
              'Active',
              style: TextStyle(
                color: AppColors.subTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
        ...pendingTasks.map(
          (task) => PersonalTaskCard(
            task: task,
            onDelete: () => _deleteTask(task.id),
            onRefresh: fetchTasks,
          ),
        ),
        if (endedTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Ended',
              style: TextStyle(
                color: AppColors.subTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
          ...endedTasks.map(
            (task) => Opacity(
              opacity: 0.5,
              child: PersonalTaskCard(
                task: task,
                onDelete: () => _deleteTask(task.id),
                onRefresh: fetchTasks,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
