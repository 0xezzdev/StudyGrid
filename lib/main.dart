import 'package:flutter/material.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/feature/group_todo/features/group_todo.dart';
import 'package:study_grid/feature/splash_screen/widget/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GroupToDo(groupId: 9),
    );
  }
}
