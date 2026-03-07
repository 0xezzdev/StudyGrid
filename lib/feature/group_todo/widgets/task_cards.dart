import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class TaskCards extends StatelessWidget {
  const TaskCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        // horizontal: 12,
        vertical: 10,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.itemsColor,
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
          border: Border.all(color: AppColors.subTextColor, width: 1.0),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CardText(text: 'Programming midterm'),
                Spacer(),

                AdminEditing(),
              ],
            ),

            Row(
              children: [
                //periorty
                NotificationContainers(
                  backgroundColor: Color(0x21FF4D6D),
                  icon: Icons.flag,
                  iconColor: Color(0xFFFF4D6D),
                  text: 'High',
                  textColor: Color(0xFFFF4D6D),
                ),
                SizedBox(width: 6),

                // Due date chip
                NotificationContainers(
                  backgroundColor: const Color.fromARGB(197, 216, 225, 230),
                  icon: Icons.calendar_today_outlined,
                  iconColor: Color(0xFF5A5A8A),
                  text: 'May 15, 2026',
                  textColor: Color(0xFF5A5A8A),
                ),
                SizedBox(width: 6),

                // Days left chip
                NotificationContainers(
                  backgroundColor: const Color.fromARGB(197, 216, 225, 230),
                  icon: Icons.timer,
                  iconColor: Color(0xFF5A5A8A),
                  text: '2 days left',
                  textColor: Color(0xFF5A5A8A),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container NotificationContainers({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuButton<String> AdminEditing() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: AppColors.subTextColor), // ده الـ ⋮

      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          /* edit logic */
        }
        if (value == 'delete') {
          /* delete logic */
        }
      },
    );
  }
}

class CardText extends StatelessWidget {
  final String text;

  const CardText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.subTextColor,
        fontSize: 20,
        fontWeight: FontWeight(1000),
        fontStyle: FontStyle.normal,
      ),
    );
  }
}
