import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_snackbar.dart';
import 'package:study_grid/core/components/custom_text_field.dart';
import 'package:study_grid/core/services/group_service.dart';
import 'package:study_grid/feature/create_group/widget/custom_appbar.dart';

class CreateGroupScreen extends StatefulWidget {
  final String userId;
  const CreateGroupScreen({super.key, required this.userId});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  // دي لرفع الصورة
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: CustomAppbar(),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // اختيار الصورة
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.itemsColor,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : null,
                                child: _imageFile == null
                                    ? const Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 30),
                            CustomTextField(
                              controller: _nameController,
                              label: 'Name',
                              prefixIcon: Icons.title_rounded,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: _descController,
                              label: 'Description',
                              prefixIcon: Icons.description_outlined,
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purplecolor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_nameController.text.isEmpty ||
                                      _descController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      CustomSnackBar(
                                        title: 'Error',
                                        message: 'Enter the name and description',
                                        color: AppColors.redColor,
                                        icon: Icons.error_outline,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _isLoading = true);
                                  try {
                                    await createNewGroup(
                                      name: _nameController.text,
                                      description: _descController.text,
                                      imageFile: _imageFile,
                                      userId: widget.userId,
                                    );
                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    print("Error: $e");
                                  } finally {
                                    if (mounted)
                                      setState(() => _isLoading = false);
                                  }
                                },
                                child: const Text(
                                  "Create Group",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
