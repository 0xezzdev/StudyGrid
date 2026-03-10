import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/services/group_service.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/feature/chat_page.dart/chat_page.dart';
import 'package:study_grid/feature/file_page.dart/files_page.dart';
import 'package:study_grid/feature/group_details/screens/more_tap/more_tap_screen.dart';

class GroupMainPage extends StatefulWidget {
  final int groupId;
  const GroupMainPage({
    super.key,
    required this.groupId,
    required String userId,
  });

  @override
  State<GroupMainPage> createState() => _GroupMainPageState();
}

class _GroupMainPageState extends State<GroupMainPage> {
  late String groupName;
  late String groupPhotoUrl;
  late String groupDesc;
  late String inviteCode;
  int membersCount = 0;
  bool isLoading = true;
  final currentUser = SupabaseService.client.auth.currentUser;
  String? get userId => currentUser?.id;
  late String userRole;

  @override
  void initState() {
    super.initState();
    _loadGroupDetails();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.purplecolor),
            ),
          )
        : DefaultTabController(
            length: 4,
            child: Scaffold(
              backgroundColor: AppColors.backgroundColor,
              appBar: AppBar(
                backgroundColor: AppColors.backgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(groupPhotoUrl),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder<int>(
                          stream: streamGroupMembersCount(widget.groupId),
                          builder: (context, snapshot) {
                            final currentCount = snapshot.data ?? membersCount;
                            return Text(
                              '$currentCount members •',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(90),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF7B61FF),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: const Color(0xFF7B61FF),
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.chat_bubble_outline, size: 20),
                          text: "Chat",
                        ),
                        Tab(
                          icon: Icon(Icons.attach_file, size: 20),
                          text: "Files",
                        ),
                        Tab(
                          icon: Icon(Icons.check_box_outlined, size: 20),
                          text: "To-Do",
                        ),
                        Tab(
                          icon: Icon(Icons.grid_view, size: 20),
                          text: "More",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7B61FF),
                      ),
                    )
                  : StreamBuilder<int>(
                      stream: streamGroupMembersCount(widget.groupId),
                      builder: (context, snapshot) {
                        final liveCount = snapshot.data ?? membersCount;

                        return TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ChatPage(
                              groupId: widget.groupId,
                              groupName: groupName,
                            ),

                            FilesPage(
                              groupId: widget.groupId,
                              usserRole: userRole,
                            ),

                            const Center(
                              child: Text(
                                "To-Do Screen Content",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            MoreTabScreen(
                              userRole: userRole,
                              membersCount:
                                  liveCount,
                              onLeaveGroup: () {
                                leaveGroup(
                                  context,
                                  userId: userId!,
                                  groupId: widget.groupId,
                                  membersCount: liveCount,
                                  userRole: userRole,
                                );
                              },
                              inviteCode: inviteCode,
                              groupId: widget.groupId,
                              onRefresh: () => _loadGroupDetails(),
                              groupName: groupName,
                              groupDesc: groupDesc,
                              groupPhotoUrl: groupPhotoUrl,
                              onDeleteGroup: () {
                                deleteGroup(
                                  context,
                                  groupId: widget.groupId,
                                  userId: userId!,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),
          );
  }

  void _loadGroupDetails() async {
    try {
      final results = await Future.wait([
        getGroupDetails(widget.groupId),
        getUserRoleInGroup(userId!, widget.groupId.toString()),
      ]);

      final data = results[0] as Map<String, dynamic>?;

      if (data != null && mounted) {
        setState(() {
          groupName = data['name'] ?? 'Group Details';
          groupPhotoUrl = data['cover_image_url'] ?? '';
          groupDesc = data['description'] ?? '';
          userRole = results[1] as String;
          inviteCode = data['invite_code'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading group: $e");
    }
  }
}
