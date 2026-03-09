import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/services/group_service.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/feature/group_details/screens/more_tap/more_tap_screen.dart';
import 'package:study_grid/feature/groups_page/groups_page.dart';

class GroupMainPage extends StatefulWidget {
  final int groupId;
  const GroupMainPage({super.key, required this.groupId});

  @override
  State<GroupMainPage> createState() => _GroupMainPageState();
}

class _GroupMainPageState extends State<GroupMainPage> {
  late String groupName;
  late String groupPhotoUrl;
  late String groupDesc;
  late String inviteCode;
  late int membersCount;
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
                        SizedBox(height: 4),
                        Text(
                          '$membersCount members •',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
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
                  : TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Center(
                          child: Text(
                            "Chat Screen Content",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Center(
                          child: Text(
                            "Files Screen Content",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Center(
                          child: Text(
                            "To-Do Screen Content",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        MoreTabScreen(
                          userRole: userRole,
                          membersCount: membersCount,
                          onLeaveGroup: () {
                            leaveGroup(
                              context,
                              userId: userId!,
                              groupId: widget.groupId,
                              membersCount: membersCount,
                              userRole: userRole,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => GroupsPage()),
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => GroupsPage()),
                            );
                          },
                        ),
                      ],
                    ),
            ),
          );
  }

  void _loadGroupDetails() async {
    try {
      final results = await Future.wait([
        getGroupDetails(widget.groupId),
        getGroupMembersCount(widget.groupId.toString()),
        getUserRoleInGroup(userId!, widget.groupId.toString()),
      ]);

      final data = results[0] as Map<String, dynamic>?;

      if (data != null && mounted) {
        setState(() {
          groupName = data['name'] ?? 'Group Details';
          groupPhotoUrl = data['cover_image_url'] ?? '';
          groupDesc = data['description'] ?? '';
          membersCount = results[1] as int;
          userRole = results[2] as String;
          inviteCode = data['invite_code'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading group: $e");
    }
  }
}
