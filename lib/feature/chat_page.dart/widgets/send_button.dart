import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';



class SendButton extends StatelessWidget {
  const SendButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.purplecolor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
        ),
      );
}