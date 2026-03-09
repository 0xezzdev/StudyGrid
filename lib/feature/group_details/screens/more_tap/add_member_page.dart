import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_snackbar.dart';
import 'package:study_grid/core/image/images_const.dart';
import 'package:study_grid/core/services/group_service.dart';
import 'package:study_grid/core/services/supabase_service.dart';

class AddMembersPage extends StatefulWidget {
  final int groupId;
  const AddMembersPage({super.key, required this.groupId});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final currentUser = SupabaseService.client.auth.currentUser;
  String? get userId => currentUser?.id;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          "Add Members",
          style: TextStyle(color: AppColors.mainTextColor),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getRegisteredContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Text(
                'there are no registered contacts in your phone',
                style: TextStyle(fontSize: 16, color: AppColors.mainTextColor),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              return user['id'] == userId ? SizedBox.shrink() : ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['avatar_url'] != null
                      ? NetworkImage(user['avatar_url'])
                      : NetworkImage(ImagesConst.defaultProfileAvatar),
                ),
                title: Text(
                  user['name'] ?? 'No Name',
                  style: TextStyle(color: AppColors.mainTextColor),
                ),
                subtitle: Text(
                  user['phone'] ?? '',
                  style: TextStyle(color: AppColors.mainTextColor),
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _addMemberToGroup(user['id']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addMemberToGroup(String userId) async {

    try {
      await addMember(context,widget.groupId, userId);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          title: 'Error',
          message: 'Failed to add member: $e',
          icon: Icons.error,
          color: Colors.red,
        ),
      );
      return;
    }
  }
  
}
