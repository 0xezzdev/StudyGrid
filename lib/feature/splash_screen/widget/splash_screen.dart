import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/feature/main_screen/main_screen.dart';
import 'package:study_grid/feature/sign_in/sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final StreamSubscription<AuthState> _authSubscription;
  
  bool _isRecoveringPassword = false;

  @override
  void initState() {
    super.initState();
    _listenToAuthChanges(); 
    
    
    WidgetsBinding.instance.addPostFrameCallback((_) => checkSession());
  }

  
  void _listenToAuthChanges() {
    _authSubscription = SupabaseService.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
     print("Supabase Auth Event Received: $event"); 
      if (event == AuthChangeEvent.passwordRecovery) {
        _isRecoveringPassword = true;
        if (mounted) {
          
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/update-password', 
            (route) => false,
          );
        }
      }
    });
  }

  Future<void> checkSession() async {
    
    await Future.delayed(const Duration(seconds: 3));
    
    
    if (!mounted || _isRecoveringPassword) return;

    try {
      final session = SupabaseService.client.auth.currentSession;
      
      _navigateTo(session != null ? const MainScreen() : const SignInScreen());
    } catch (e) {
      _navigateTo(const SignInScreen());
    }
  }

  void _navigateTo(Widget screen) {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (_) => screen), 
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view_rounded, color: AppColors.cyanColor, size: 50),
            const SizedBox(width: 12),
            Text(
              "Study",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: AppColors.purplecolor,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              "Grid",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: AppColors.cyanColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}