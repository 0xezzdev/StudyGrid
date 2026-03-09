import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_text_field.dart';
import 'package:study_grid/core/components/custom_snackbar.dart';
import 'package:study_grid/core/services/group_service.dart';
import 'package:study_grid/core/services/storage_service.dart';

class EditGroupPage extends StatefulWidget {
  final int groupId;
  final String currentName;
  final String currentDesc;
  final String currentImg;
  final VoidCallback onUpdate;
  final String userId;
  final String userRole;

  const EditGroupPage({
    super.key,
    required this.groupId,
    required this.currentName,
    required this.currentDesc,
    required this.currentImg,
    required this.onUpdate, required this.userId, required this.userRole,
  });

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  File? _selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _descController = TextEditingController(text: widget.currentDesc);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Edit Group",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.itemsColor,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : NetworkImage(widget.currentImg) as ImageProvider,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.purplecolor,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // الحقول
            CustomTextField(
              controller: _nameController,
              label: 'Group Name',
              prefixIcon: Icons.group_work_outlined,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _descController,
              label: 'Group Description',
              prefixIcon: Icons.description_outlined,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purplecolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : _saveChanges,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
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

  void _saveChanges() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => isLoading = true);

    String? newImageUrl;

    if (_selectedImage != null) {
      newImageUrl = await StorageService().uploadFile(
        file: _selectedImage!,
        bucketName: 'group_avatars',
      );
    }

    bool isSuccess = await updateGroupDetails(
      groupId: widget.groupId,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      imageUrl: newImageUrl, userId: widget.userId, userRole: widget.userRole,
    );

    if (isSuccess && mounted) {
      widget.onUpdate();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          title: 'Success',
          message: 'Group updated successfully!',
          color: AppColors.greenColor,
          icon: Icons.check_circle,
        ),
      );
    } else {
      setState(() => isLoading = false);
    }
  }
}
