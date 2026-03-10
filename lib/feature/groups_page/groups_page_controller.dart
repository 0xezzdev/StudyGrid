import 'package:flutter/material.dart';
import 'package:study_grid/feature/groups_page/groups_page.dart';

class GroupsPageController extends StatefulWidget {
  const GroupsPageController({super.key});

  @override
  State<GroupsPageController> createState() => _GroupsPageControllerState();
}

class _GroupsPageControllerState extends State<GroupsPageController> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: GlobalKey<NavigatorState>(),
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) {
            return const GroupsPage();
          },
        );
      },
    );
  }
}
