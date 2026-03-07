import 'package:flutter/material.dart';
import 'package:study_grid/feature/settings/screens/settings_list_home.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: GlobalKey<NavigatorState>(),
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) {
            return const SettingsListHome();
          },
        );
      },
    );
  }
}
