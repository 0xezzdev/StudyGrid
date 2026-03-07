import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        Text("Create Group",style: TextStyle(color: AppColors.mainTextColor,fontSize: 20,fontWeight: FontWeight.bold)),
      ],
    );
  }
}
