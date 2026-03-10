import 'package:flutter/material.dart';

class GroupTask {
  final int id;
  final String title;
  final String priority;
  final DateTime dueDate;
  final String status;

  GroupTask({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    required this.status,
  });

  factory GroupTask.fromJson(Map<String, dynamic> json) {
    return GroupTask(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
    );
  }
}
