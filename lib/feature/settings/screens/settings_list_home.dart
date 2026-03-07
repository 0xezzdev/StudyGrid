import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/models/settings_items_list.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/feature/settings/screens/about.dart';
import 'package:study_grid/feature/settings/screens/notifications_settins.dart';
import 'package:study_grid/feature/settings/screens/privacy_and_security.dart';
import 'package:study_grid/feature/settings/screens/profile_information.dart';
import 'package:study_grid/feature/settings/widget/settings_items.dart';
import 'package:study_grid/feature/sign_in/sign_in_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsListHome extends StatefulWidget {
  const SettingsListHome({super.key});

  @override
  State<SettingsListHome> createState() => _SettingsListHomeState();
}

class _SettingsListHomeState extends State<SettingsListHome> {
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? "User";
    final userPhoto = user?.userMetadata?['avatar_url'] != null
        ? "${user!.userMetadata!['avatar_url']}?v=${DateTime.now().millisecondsSinceEpoch}"
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 26.0, right: 26.0, top: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  // height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: userPhoto != null
                              ? NetworkImage(userPhoto)
                              : NetworkImage(
                                  'https://pexiueyzeprdnjeluvin.supabase.co/storage/v1/object/public/profile_photo/df_profile.jpg',
                                ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "$userName",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  // Adjust the height as needed
                  child: ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: SettingsItemsList().items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SettingsItems(
                        icon: SettingsItemsList().items[index].icon,
                        title: SettingsItemsList().items[index].title,
                        subtitle: SettingsItemsList().items[index].subtitle,
                        onTap: () {
                          if (SettingsItemsList().items[index].title ==
                              'Profile Information') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProfileInformation(),
                              ),
                            ).then((_) => setState(() {}));
                            // Handle profile information tap
                          } else if (SettingsItemsList().items[index].title ==
                              'Privacy and Security') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyAndSecurity(),
                              ),
                            );
                            // Handle privacy and security tap
                          } else if (SettingsItemsList().items[index].title ==
                              'Notifications') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsSettins(),
                              ),
                            );
                            // Handle notifications tap
                          } else if (SettingsItemsList().items[index].title ==
                              'About') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const About(),
                              ),
                            );
                            // Handle about tap
                          }
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 10);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.itemsColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.redColor),
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      await SupabaseService.client.auth.signOut();
                      if (mounted) {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.redColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
