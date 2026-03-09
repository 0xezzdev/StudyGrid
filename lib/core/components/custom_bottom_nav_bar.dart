import 'dart:ui';

import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  final bool hasChatNotification;
  final bool hasAlertsNotification;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.hasChatNotification = false,
    this.hasAlertsNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          height: 85,
          decoration: BoxDecoration(
            color: Colors.transparent.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, "Home", 0),
              _buildNavItem(Icons.task_alt, "To-Do", 1),
              _buildNavItem(
                Icons.group_outlined,
                "Groups",
                2,
                isSelected: true,
              ),
              _buildNavItem(
                Icons.notifications_none,
                "Alerts",
                3,
                hasNotification: hasAlertsNotification,
              ),
              _buildNavItem(
                Icons.settings_outlined,
                "Settings",
                4,
                hasNotification: hasChatNotification,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    bool isSelected = false,
    bool hasNotification = false,
  }) {
    final bool active = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: active
                    ? BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF6C63FF),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  icon,
                  color: active ? const Color(0xFF6C63FF) : Colors.grey,
                  size: 26,
                ),
              ),
              if (hasNotification)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? Color(0xFF6C63FF) : Colors.grey,
              fontSize: 10,
              fontFamily: 'Monospace',
            ),
          ),
        ],
      ),
    );
  }
}
