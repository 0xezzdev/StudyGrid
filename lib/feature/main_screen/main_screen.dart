import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_bottom_nav_bar.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/core/services/token_services.dart';
import 'package:study_grid/feature/groups_page/groups_page_controller.dart';
import 'package:study_grid/feature/home/home_page.dart';
import 'package:study_grid/feature/notification/alert_page.dart';
import 'package:study_grid/feature/settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final currentUser = SupabaseService.client.auth.currentUser;
  String? get userId => currentUser?.id;

  @override
void initState() {
  super.initState();
  updateFCMToken(userId: userId ?? ''
  );
}

  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    const Center(
      child: Text(
        'To-Do Screen',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    GroupsPageController(),
    AlertPage(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: false,
      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
