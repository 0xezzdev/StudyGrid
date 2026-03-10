import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/feature/splash_screen/widget/splash_screen.dart';
import 'package:study_grid/feature/reset_password/update_password_screen.dart';
import 'package:study_grid/feature/sign_in/sign_in_screen.dart';
import 'package:study_grid/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission for notifications');
  }

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  String? token = await FirebaseMessaging.instance.getToken();
  print("My Fresh FCM Token: $token");

  await SupabaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Grid',

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),

        '/login': (context) => const SignInScreen(),

        '/update-password': (context) => const UpdatePasswordScreen(),
      },
    );
  }
}
