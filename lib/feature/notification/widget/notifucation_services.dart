import 'package:flutter/material.dart';
import 'package:study_grid/core/models/app_notification.dart';
import 'package:study_grid/core/services/supabase_service.dart';

class NotificationStreamBuilder extends StatelessWidget {
  const NotificationStreamBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: SupabaseService.client
          .from('notification')
          .stream(primaryKey: ['id'])
          .eq('user_id', SupabaseService.client.auth.currentUser!.id)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final notifications = snapshot.data!
            .map((json) => AppNotification.fromJson(json))
            .toList();

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final item = notifications[index];
            return ListTile(
              leading: Icon(
                item.type == 'chat' ? Icons.chat : Icons.assignment,
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(item.body),
              trailing: !item.isRead
                  ? CircleAvatar(radius: 5, backgroundColor: Colors.red)
                  : null,
              onTap: () {
                // هنا كود الـ Navigation حسب الـ referenceId
              },
            );
          },
        );
      },
    );
  }
}
