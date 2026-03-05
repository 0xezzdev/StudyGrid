import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class WelcomeContainer extends StatelessWidget {
  const WelcomeContainer({
    super.key, required this.unreadMessages,
  });

  final int unreadMessages ;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 24, 24, 35),
            Color(0xFF2D2D44),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: TextStyle(
              color: AppColors.mainTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You have $unreadMessages unread messages',
            style: TextStyle(color: AppColors.subTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
