import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/image/images_const.dart';
import 'package:study_grid/core/services/group_service.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/feature/group_details/screens/more_tap/add_member_page.dart';
import 'package:study_grid/feature/group_details/screens/more_tap/edit_group_page.dart';

class MoreTabScreen extends StatelessWidget {
  final String userRole;
  final int membersCount;
  final VoidCallback onLeaveGroup;
  final VoidCallback onDeleteGroup;
  final String inviteCode;
  final int groupId;
  final VoidCallback onRefresh;
  final String groupName;
  final String groupDesc;
  final String groupPhotoUrl;

  const MoreTabScreen({
    super.key,
    required this.userRole,
    required this.membersCount,
    required this.onLeaveGroup,
    required this.inviteCode,
    required this.groupId,
    required this.onRefresh,
    required this.groupName,
    required this.groupDesc,
    required this.groupPhotoUrl, required this.onDeleteGroup,
  });

  @override
  Widget build(BuildContext context) {
    bool isAdmin = userRole == 'admin';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        if (isAdmin) ...[
          _buildSectionHeader("Admin Tools"),
          _buildMoreItem(Icons.edit_outlined, "Edit Group Details", () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditGroupPage(
                  groupId: groupId,
                  currentName: groupName,
                  currentDesc: groupDesc,
                  currentImg: groupPhotoUrl,
                  onUpdate: onRefresh,
                  userId: SupabaseService.client.auth.currentUser!.id,
                  userRole: userRole,
                ),
              ),
            );
          }),
          _buildMoreItem(Icons.person_add, "Add Members", () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddMembersPage(groupId: groupId),
              ),
            );
          }),
          _buildMoreItem(Icons.pin, "Invite Code", () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    "Invite Code",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainTextColor,
                    ),
                  ),
                  backgroundColor: AppColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.itemsColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                inviteCode,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.purplecolor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: inviteCode),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Code copied to clipboard!"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ],
                );
              },
            );
          }),
          const SizedBox(height: 20),
        ],

        _buildSectionHeader("General"),
        _buildMoreItem(
          Icons.people_alt_outlined,
          "Members ($membersCount)",
          () {
            _showMembersSheet(context, groupId, userRole, onRefresh);
          },
        ),
        _buildMoreItem(
          Icons.notifications_none_rounded,
          "Notifications Settings",
          () {},
        ),

        const SizedBox(height: 40),

        _buildButton(onLeaveGroup, title: "Leave Group", icon: Icons.exit_to_app),
        const SizedBox(height: 20),
        if (isAdmin)
          _buildButton(onDeleteGroup, title: "Delete Group", icon: Icons.delete)
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF7B61FF), // Purple color
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMoreItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: AppColors.itemsColor,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white70, size: 22),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white24,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildButton(
    VoidCallback onTap, {
    required String title,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.redAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showMembersSheet(
  BuildContext context,
  int groupId,
  String? userRole,
  VoidCallback onRefresh,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.backgroundColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: getGroupMembers(groupId.toString()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final members = snapshot.data ?? [];

              return Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Group Members",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final profile = member['profiles'];
                        return _buildMemberTile(
                          context,
                          name: profile['name'] ?? 'Unknown',
                          role: member['role'] ?? 'member',
                          imageUrl:
                              profile['avatar_url'] ??
                              ImagesConst.defaultProfileAvatar,
                          userRole: userRole ?? 'member',
                          memberId: profile['id'],
                          userId: SupabaseService.client.auth.currentUser!.id,
                          groupId: groupId,
                          onRefresh: onRefresh,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

Widget _buildMemberTile(
  BuildContext context, {
  required String name,
  required String role,
  required String imageUrl,
  required String userRole,
  required String memberId,
  required String userId,
  required int groupId,
  required VoidCallback onRefresh,
}) {
  bool isAdmin = userRole == 'admin';
  bool isTargetAdmin = role.toLowerCase() == 'admin';

  return ListTile(
    leading: CircleAvatar(
      backgroundColor: AppColors.purplecolor.withValues(alpha: 0.2),
      backgroundImage: NetworkImage(imageUrl),
    ),
    title: Text(
      name,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Text(
      role,
      style: TextStyle(
        color: role.toLowerCase() == 'admin'
            ? AppColors.purplecolor
            : Colors.grey,
        fontSize: 12,
      ),
    ),
    trailing: (isAdmin && memberId != userId)
        ? PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            color: AppColors.itemsColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (value) {
              if (value == 'make_admin') {
                updateRole(
                  context,
                  targetUserId: memberId,
                  newRole: 'admin',
                  groupId: groupId,
                  onRefresh: onRefresh,
                  userId: userId,
                  userRole: userRole,
                );
              } else if (value == 'remove') {
                removeFromGroup(
                  context,
                  targetUserId: memberId,
                  groupId: groupId,
                  onRefresh: onRefresh,
                  userId: userId,
                  userRole: userRole,
                );
              }
            },
            itemBuilder: (context) => [
              if (!isTargetAdmin)
                const PopupMenuItem(
                  value: 'make_admin',
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text("Make Admin", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_remove_outlined,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Remove from Group",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          )
        : null,
  );
}
