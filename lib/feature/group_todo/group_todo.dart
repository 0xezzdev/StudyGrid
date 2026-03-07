import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/feature/group_todo/widgets/task_cards.dart';
//import 'package:dotted_border/dotted_border.dart';

class Group_ToDo extends StatelessWidget {
  const Group_ToDo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          // main coloumn
          child: Column(
            children: [
              Container(
                // margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.itemsColor,
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                  border: Border.all(color: AppColors.subTextColor, width: 1.0),
                ),
                child:
                    // ... inside a build method ...
                    Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: AppColors.subTextColor,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Add new task',
                          style: TextStyle(
                            color: AppColors.subTextColor,
                            fontSize: 15.0, // Text size
                            fontWeight: FontWeight(500),
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
              ),

              // list view for tasks cards
              TaskCards(),
            ],
          ),
        ),
      ),
    );
  }
}
