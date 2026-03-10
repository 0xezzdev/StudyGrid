import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.groupTitle,
    required this.studentRule,
    required this.aboutGroup,
    required this.leftColor,
    required this.groupImage,
    required this.notificationNumber,
    required this.memberCountWidget,
    this.onTap,
  });

  final String groupTitle;
  final String studentRule;
  final String aboutGroup;
  final Color leftColor;
  final String groupImage;
  final String notificationNumber;
  final Widget memberCountWidget;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.itemsColor,
          borderRadius: BorderRadius.circular(16),
          //the left color in card
          border: Border(left: BorderSide(color: leftColor, width: 4)),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 25, backgroundImage: NetworkImage(groupImage)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        groupTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Container(
                      //   padding: EdgeInsets.all(6),
                      //   decoration: BoxDecoration(
                      //     color: Color(0xFF6366F1),
                      //     shape: BoxShape.circle,
                      //   ),
                      //   child: Text(
                      //     notificationNumber,
                      //     style: TextStyle(color: Colors.white, fontSize: 10),
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFF6366F1).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      studentRule,
                      style: TextStyle(
                        color: AppColors.purplecolor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    aboutGroup,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      memberCountWidget,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
