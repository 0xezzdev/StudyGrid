import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class CardText extends StatelessWidget {
  final String text;
  final bool isCompleted;

  const CardText({super.key, required this.text, this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: isCompleted ? AppColors.subTextColor : AppColors.mainTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        decoration: isCompleted
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        decorationColor: AppColors.subTextColor,
      ),
    );
  }
}
