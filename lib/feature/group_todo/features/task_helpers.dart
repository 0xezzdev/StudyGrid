import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

Color getPriorityColor(String priority) {
  switch (priority) {
    case 'high':
      return AppColors.redColor;
    case 'med':
      return AppColors.orangeColor;
    case 'low':
      return AppColors.greenColor;
    default:
      return AppColors.subTextColor;
  }
}

Color getPriorityBgColor(String priority) {
  switch (priority) {
    case 'high':
      return Color(0x21FF4D6D);
    case 'med':
      return Color(0x21F4A340);
    case 'low':
      return Color(0x214ADE80);
    default:
      return Color(0xFF1E1E2E);
  }
}

String getPriorityLabel(String priority) {
  switch (priority) {
    case 'high':
      return 'High';
    case 'med':
      return 'Medium';
    case 'low':
      return 'Low';
    default:
      return '';
  }
}

String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String getDaysLeft(DateTime dueDate) {
  final int diff = dueDate.difference(DateTime.now()).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff < 0) return 'Ended';
  return '$diff days left';
}
