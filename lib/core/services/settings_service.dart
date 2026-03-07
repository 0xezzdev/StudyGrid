import 'dart:io';

import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_snackbar.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> updateProfile(
  BuildContext context, {
  required String name,
  required String phone,
  File? imageFile,
  required User user,
}) async {
  try {
    String? imageUrl;

    if (imageFile != null) {
      final fileName = '${user!.id}_profile.jpg';

      await SupabaseService.client.storage
          .from('profile_photo')
          .upload(
            fileName,
            imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      imageUrl = SupabaseService.client.storage
          .from('profile_photo')
          .getPublicUrl(fileName);
    }

    Map<String, dynamic> updates = {'full_name': name, 'phone': phone};

    if (imageUrl != null) {
      updates['avatar_url'] = imageUrl;
    }

    await SupabaseService.client.auth.updateUser(UserAttributes(data: updates));

    await SupabaseService.client
        .from('users')
        .update({
          'name': name,
          'phone': phone,
          if (imageUrl != null) 'avatar_url': imageUrl,
        })
        .eq('id', user!.id);

    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        title: 'Success',
        message: 'Profile updated successfully!',
        icon: Icons.check,
        color: AppColors.greenColor,
      ),
    );
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        title: 'Error',
        message: 'Failed to update profile. Please try again.',
        icon: Icons.error,
        color: AppColors.redColor,
      ),
    );
  }
}

Future<void> updatePassword(String newPassword, BuildContext context) async {
  try {
    await SupabaseService.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        title: 'Success',
        message: 'Password updated successfully!',
        icon: Icons.check,
        color: AppColors.greenColor,
      ),
    );
    Navigator.pop(context);
  } catch (e) {
    print("Error updating password: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        title: 'Error',
        message: 'Failed to update password. Please try again.',
        icon: Icons.error,
        color: AppColors.redColor,
      ),
    );
  }
}
