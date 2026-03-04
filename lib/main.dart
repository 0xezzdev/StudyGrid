import 'package:flutter/material.dart';
import 'package:study_grid/feature/splash_screen/widget/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //return splash screen
    return MaterialApp(home: SplashScreen());
  }
}
