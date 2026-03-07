import 'package:flutter/material.dart';
import 'package:study_grid/feature/settings/widget/settings_items.dart';

class SettingsItemsList {
  List<SettingsItems> items = [
    SettingsItems(
      icon: Icons.person,
      title: 'Profile Information',
      subtitle: 'View and edit your profile information',
    ),
    SettingsItems(
      icon: Icons.lock,
      title: 'Privacy and Security',
      subtitle: 'Adjust your privacy and security settings',
    ),
    SettingsItems(
      icon: Icons.lock,
      title: 'Notifications',
      subtitle: 'Manage your notification preferences',
    ),
    SettingsItems(
      icon: Icons.help,
      title: 'About',
      subtitle: 'Learn more about the app and its features',
    ),
  ];
}