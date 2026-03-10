import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class CardText extends StatelessWidget {
  final String text;

  const CardText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.mainTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
