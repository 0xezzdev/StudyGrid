import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class GroupsPageAppbar extends StatelessWidget {
  const GroupsPageAppbar({
    super.key, this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.sentMessageMainColor,
          child: Text(
            "S",
            style: TextStyle(
              color: AppColors.mainTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          'StudyGrid',
          style: TextStyle(
            color: AppColors.mainTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        IconButton(
          onPressed: onPressed,
          icon: Icon(Icons.settings_outlined),
          color: AppColors.mainTextColor,
        ),
      ],
    );
  }
}
