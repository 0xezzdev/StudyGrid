import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  Stream<int> getGroupsCountStream() {
    final userId = supabase.auth.currentUser!.id;
    return supabase
        .from('GROUP_MEMBER')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => data.length);
  }

  Stream<int> getTasksCountStream() async* {
    final userId = supabase.auth.currentUser!.id;

    final List<Map<String, dynamic>> groupsJoined = await supabase
        .from('GROUP_MEMBER')
        .select('group_id')
        .eq('user_id', userId);

    final List<Object> groupIds = groupsJoined
        .map((e) => e['group_id'] as Object)
        .toList();

    if (groupIds.isEmpty) {
      yield 0;
    } else {
      yield* supabase
          .from('group_todo')
          .stream(primaryKey: ['id'])
          .inFilter('group_id', groupIds)
          .map((data) => data.length);
    }
  }

  Stream<List<Map<String, dynamic>>> getActivitiesStream() {
    final userId = supabase.auth.currentUser!.id;
    return supabase
        .from('notification')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(5);
  }

  String formatTimeAgo(String timestamp) {
    final DateTime notificationTime = DateTime.parse(timestamp);
    final duration = DateTime.now().difference(notificationTime);

    if (duration.inSeconds < 60) return 'Now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    if (duration.inDays == 1) return 'Yesterday';
    return '${duration.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                getGreeting(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here\'s your study overview for today.',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  StreamBuilder<int>(
                    stream: getTasksCountStream(),
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        icon: Icons.access_time,
                        iconColor: Colors.orange,
                        title: 'Due Today',
                        value: '${snapshot.data ?? 0} tasks',
                        valueColor: Colors.orange,
                      );
                    },
                  ),
                  const SizedBox(width: 15),

                  StreamBuilder<int>(
                    stream: getGroupsCountStream(),
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        icon: Icons.groups_outlined,
                        iconColor: Colors.deepPurpleAccent,
                        title: 'Groups',
                        value: '${snapshot.data ?? 0} active',
                        valueColor: Colors.deepPurpleAccent,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.itemsColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: getActivitiesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepPurpleAccent,
                          ),
                        );
                      }
                      final activities = snapshot.data ?? [];
                      if (activities.isEmpty) {
                        return const Center(
                          child: Text(
                            'No recent activity',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          return _activityItem(
                            activity['title'] ?? 'New Notification',
                            formatTimeAgo(activity['created_at']),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.itemsColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityItem(String text, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning! 👋';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon! ☀️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening! 🌆';
    } else {
      return 'Good night! 🌙';
    }
  }
}
