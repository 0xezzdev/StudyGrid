import 'package:flutter/material.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/feature/splash_screen/widget/splash_screen.dart';
import 'package:study_grid/feature/reset_password/update_password_screen.dart'; 
import 'package:study_grid/feature/sign_in/sign_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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