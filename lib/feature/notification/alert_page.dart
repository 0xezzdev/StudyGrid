import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text(
            'Alerts',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () async {
                await supabase
                    .from('notification')
                    .update({'is_read': true})
                    .eq('user_id', userId)
                    .eq(
                      'is_read',
                      false,
                    );
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('notification')
            .stream(primaryKey: ['id'])
            .eq('user_id', userId)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No alerts yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              final bool isRead = item['is_read'] ?? false;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.itemsColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isRead
                      ? null
                      : Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                ),
                child: ListTile(
                  leading: _getIcon(item['type']),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    item['body'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: !isRead
                      ? const CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.blueAccent,
                        )
                      : null,
                  onTap: () async {
                    if (!isRead) {
                      // التحديث في قاعدة البيانات
                      await supabase
                          .from('notification')
                          .update({'is_read': true})
                          .match({
                            'id': item['id'],
                          }); // استخدام match أضمن أحياناً من eq في الـ streams
                    }

                    // الـ Navigation
                    if (item['type'] == 'chat') {
                      // الانتقال للشات
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getIcon(String? type) {
    IconData iconData;
    Color color;
    switch (type) {
      case 'chat':
        iconData = Icons.chat_bubble_outline;
        color = Colors.purpleAccent;
        break;
      case 'material':
        iconData = Icons.attach_file;
        color = Colors.blueAccent;
        break;
      case 'todo':
        iconData = Icons.task_alt;
        color = Colors.orangeAccent;
        break;
      default:
        iconData = Icons.notifications_none;
        color = Colors.grey;
    }
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}

