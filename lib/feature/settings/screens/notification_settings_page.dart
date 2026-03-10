import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('users')
        .select('notifications_enabled')
        .eq('id', userId)
        .single();

    setState(() {
      _notificationsEnabled = data['notifications_enabled'] ?? true;
      _isLoading = false;
    });
  }

  // فنكشن تحديث الحالة والـ Token
  Future<void> _toggleNotifications(bool value) async {
    try {
      setState(() => _notificationsEnabled = value);
      final userId = supabase.auth.currentUser!.id;

      String? token;
      if (value) {
        token = await FirebaseMessaging.instance.getToken();
      }

      await supabase
          .from('users')
          .update({'notifications_enabled': value, 'fcm_token': token})
          .eq('id', userId);

      print("Success: Notification settings updated!");
    } catch (e) {
      // لو حصل مشكلة، بنرجع السويتش مكانه عشان المستخدم ميتلخبطش
      setState(() => _notificationsEnabled = !value);
      print("Error updating settings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.itemsColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Push Notifications',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Receive alerts for messages and tasks',
                        style: TextStyle(color: Colors.grey),
                      ),
                      secondary: const Icon(
                        Icons.notifications_active,
                        color: Colors.blueAccent,
                      ),
                      value: _notificationsEnabled,
                      activeColor: Colors.blueAccent,
                      onChanged: (bool value) => _toggleNotifications(value),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'When disabled, you will not receive any notifications even if the app is running.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }
}
