import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';

class SettingsItems extends StatelessWidget {
  const SettingsItems({
    super.key, required this.icon, required this.title, required this.subtitle, this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.itemsColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.greenColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppColors.itemsColor),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppColors.subTextColor, fontSize: 14,fontWeight: FontWeight.w400),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: AppColors.subTextColor, size: 16),
        onTap: onTap,
      ),
    );
  }
}
