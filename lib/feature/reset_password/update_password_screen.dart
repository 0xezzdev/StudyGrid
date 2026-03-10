import 'package:flutter/material.dart';
import 'package:study_grid/core/components/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_text_field.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: 'Success',
            message: 'Your password has been updated.',
            icon: Icons.check,
            color: AppColors.greenColor,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: 'Error',
            message: error.message,
            icon: Icons.error,
            color: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: 'Error',
            message: 'An unexpected error occurred',
            icon: Icons.error,
            color: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.cyanColor,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  "New Password",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Set your new password to secure your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.subTextColor, fontSize: 16),
                ),
                const SizedBox(height: 40),

                CustomTextField(
                  controller: _passwordController,
                  label: "New Password",
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Please enter a password";
                    if (value.length < 6)
                      return "Password must be at least 6 characters";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  prefixIcon: Icons.lock_reset_outlined,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Please confirm your password";
                    if (value != _passwordController.text)
                      return "Passwords do not match";
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.cyan),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purplecolor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _updatePassword,
                          child: const Text(
                            "Update Password",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(
                    "Back to Login",
                    style: TextStyle(color: AppColors.subTextColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
