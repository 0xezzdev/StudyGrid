
import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class AddGroupButton extends StatelessWidget {
  const AddGroupButton({super.key, this.onPressed});

  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        onPressed: onPressed,
        child: Text(
          "Add Group",
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
