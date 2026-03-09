import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_snackbar.dart';
import 'package:study_grid/core/image/images_const.dart';
import 'package:study_grid/core/services/settings_service.dart';
import 'package:study_grid/core/services/supabase_service.dart';

class ProfileInformation extends StatefulWidget {
  const ProfileInformation({super.key});

  @override
  State<ProfileInformation> createState() => _ProfileInformationState();
}

class _ProfileInformationState extends State<ProfileInformation> {
  final user = SupabaseService.client.auth.currentUser;
  File? _imageFile;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: user?.userMetadata?['full_name'] ?? "",
    );
    _phoneController = TextEditingController(
      text: user?.userMetadata?['phone'] ?? "",
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile Information',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.itemsColor,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (user?.userMetadata?['avatar_url'] != null
                                  ? NetworkImage(
                                      user!.userMetadata!['avatar_url'],
                                    )
                                  : const NetworkImage(
                                      ImagesConst.defaultProfileAvatar,
                                    ))
                              as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            buildProfileField(
              "Full Name",
              _nameController,
              Icons.person_outline,
            ),
            const SizedBox(height: 20),
            buildProfileField(
              "Phone Number",
              _phoneController,
              Icons.phone_android_outlined,
            ),
            const SizedBox(height: 20),

            buildProfileField(
              "Email Address",
              TextEditingController(text: user?.email),
              Icons.email_outlined,
              readOnly: true,
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  if (_nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        title: "Error",
                        message: "Name cannot be empty",
                        icon: Icons.error,
                        color: AppColors.redColor,
                      ),
                    );
                    return;
                  }
                  if (_phoneController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        title: "Error",
                        message: "Phone number cannot be empty",
                        icon: Icons.error,
                        color: AppColors.redColor,
                      ),
                    );
                    return;
                  }
                  await updateProfile(
                    context,
                    name: _nameController.text.trim(),
                    phone: _phoneController.text.trim(),
                    imageFile: _imageFile,
                    user: user!,
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.greenAccent, size: 20),
            filled: true,
            fillColor: AppColors.itemsColor.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
