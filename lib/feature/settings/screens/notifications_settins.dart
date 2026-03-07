import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class NotificationsSettins extends StatefulWidget {
  const NotificationsSettins({super.key});

  @override
  State<NotificationsSettins> createState() => _NotificationsSettinsState();
}

class _NotificationsSettinsState extends State<NotificationsSettins> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'This is the Notifications screen.',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
