import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {
  final String title;
  final String message;
  final Color color;
  final IconData icon;

  CustomSnackBar({
    super.key,
    required this.title,
    required this.message,
    this.color = const Color(0xFF303030),
    required this.icon,
  }) : super(
         elevation: 0,
         backgroundColor: Colors.transparent,
         behavior: SnackBarBehavior.floating,
         content: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: color,
             borderRadius: BorderRadius.circular(15),
             boxShadow: const [
               BoxShadow(
                 color: Colors.black26,
                 blurRadius: 10,
                 offset: Offset(0, 4),
               ),
             ],
           ),
           child: Row(
             children: [
               Icon(icon, color: Colors.white, size: 30),
               const SizedBox(width: 15),
               Expanded(
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       title,
                       style: const TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 16,
                         color: Colors.white,
                       ),
                     ),
                     Text(
                       message,
                       style: const TextStyle(
                         fontSize: 14,
                         color: Colors.white70,
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ),
       );
}
