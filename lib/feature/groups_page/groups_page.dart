import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
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
                child: GroupsPageAppbar(onPressed: () {}),
              ),
              WelcomeContainer(unreadMessages: 16),
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
                  AddGroupButton(onPressed: () {}),
                ],
              ),

              SizedBox(height: 20),

              GroupCard(
                groupTitle: 'title',
                studentRule: 'admin',
                aboutGroup: 'about group',
                leftColor: AppColors.greenColor,
                groupImage:
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRs8axQKOxrwClMO7kPV88broq98IS8bpok2A&s',
                notificationNumber: '5',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
