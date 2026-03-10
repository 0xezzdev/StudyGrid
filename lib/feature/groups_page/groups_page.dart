import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_search_field.dart';
import 'package:study_grid/core/components/custom_snackbar.dart';
import 'package:study_grid/core/components/custom_text_field.dart';
import 'package:study_grid/core/services/group_service.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/feature/create_group/create_group_screen.dart';
import 'package:study_grid/feature/group_details/group_main_page.dart';
import 'package:study_grid/feature/groups_page/widgets/add_group_button.dart';
import 'package:study_grid/feature/groups_page/widgets/group_card.dart';
import 'package:study_grid/feature/groups_page/widgets/groups_page_appbar.dart';
import 'package:study_grid/feature/groups_page/widgets/welcome_continaer.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final currentUser = SupabaseService.client.auth.currentUser;
  String? get userId => currentUser?.id;
  final _inviteCodeController = TextEditingController();
  final _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 8),
                child: GroupsPageAppbar(),
              ),
              WelcomeContainer(unreadMessages: 16),
              SizedBox(height: 20),

              CustomSearchField(
                controller: _searchController,
                hint: "Search Groups...",
                onChange: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "My Groups",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.subTextColor,
                    ),
                  ),
                  Spacer(),
                  AddGroupButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: AppColors.backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Center(
                              child: Text(
                                "Add Group",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mainTextColor,
                                ),
                              ),
                            ),
                            content: SizedBox(
                              height: 100,
                              child: Column(
                                children: [
                                  AddGroupButton(
                                    width: 150,
                                    title: "Create Group",
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateGroupScreen(
                                                userId: userId!,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  AddGroupButton(
                                    width: 150,
                                    title: "Join in a group",
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                AppColors.backgroundColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            title: Center(
                                              child: Text(
                                                "Enter Invite code",
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppColors.mainTextColor,
                                                ),
                                              ),
                                            ),
                                            content: SizedBox(
                                              height: 150,
                                              child: Column(
                                                children: [
                                                  CustomTextField(
                                                    controller:
                                                        _inviteCodeController,
                                                    label: 'Invite Code',
                                                    prefixIcon: Icons.password,
                                                  ),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          AppColors.purplecolor,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      if (_inviteCodeController
                                                          .text
                                                          .trim()
                                                          .isEmpty)
                                                        return;
                                                      final check = await joinGroup(
                                                        inviteCode:
                                                            _inviteCodeController
                                                                .text
                                                                .trim(),
                                                        userId: userId!,
                                                      );
                                                      if (mounted) {
                                                        if (check == null) {
                                                          _inviteCodeController
                                                              .clear();
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );

                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            CustomSnackBar(
                                                              title: 'Success',
                                                              message:
                                                                  'You have successfully joined the group',
                                                              color: AppColors
                                                                  .greenColor,
                                                              icon: Icons
                                                                  .check_circle,
                                                            ),
                                                          );
                                                          _inviteCodeController
                                                              .clear();
                                                        } else {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );

                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            CustomSnackBar(
                                                              title: 'Error',
                                                              message: '$check',
                                                              color: AppColors
                                                                  .redColor,
                                                              icon: Icons
                                                                  .error_outline,
                                                            ),
                                                          );
                                                          _inviteCodeController
                                                              .clear();
                                                        }
                                                      }
                                                    },
                                                    child: const Text(
                                                      "Join",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    title: 'Add Group',
                  ),
                ],
              ),
              SizedBox(height: 20),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: myGroupsStream(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.purplecolor,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Center(
                        child: Text(
                          "There is no Groups",
                          style: TextStyle(color: AppColors.subTextColor),
                        ),
                      ),
                    );
                  }

                  final filteredList = snapshot.data!.where((item) {
                    final groupName = item['group_name']
                        .toString()
                        .toLowerCase();
                    return groupName.contains(searchQuery.toLowerCase());
                  }).toList();

                  if (searchQuery.isNotEmpty && filteredList.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: AppColors.subTextColor,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "There is no groups",
                              style: TextStyle(
                                color: AppColors.subTextColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView.separated(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return GroupCard(
                          groupTitle: item['group_name'],
                          studentRule: item['role'],
                          aboutGroup: item['group_desc'] ?? "",
                          leftColor: AppColors.greenColor,
                          groupImage: item['group_img'],
                          notificationNumber: '9',
                          memberCountWidget: StreamBuilder<int>(
                            stream: streamGroupMembersCount(item['group_id']),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              return Text(
                                '$count members',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GroupMainPage(
                                  groupId: item['group_id'],
                                  userId: userId!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 20);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
