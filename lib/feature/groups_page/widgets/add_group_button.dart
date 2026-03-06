
import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class AddGroupButton extends StatelessWidget {
  const AddGroupButton({super.key, this.onPressed, required this.title, this.heigt=30, this.width=100});

  final void Function()? onPressed;
  final String title;
  final double heigt;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: heigt,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        onPressed: onPressed,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.purplecolor,
          ),
        ),
      ),
    );
  }
}
