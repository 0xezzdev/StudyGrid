import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_text_field.dart';
import 'package:study_grid/core/services/auth_service.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await _authService.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phone: phoneController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    if (mounted) setState(() => isLoading = false);
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
              crossAxisAlignment: CrossAxisAlignment.start, // العنوان على الجنب
              children: [
                const SizedBox(height: 40),
                // اللوجو والاسم في النص
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.grid_view_rounded, color: AppColors.cyanColor, size: 60),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Study", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.purplecolor)),
                          const SizedBox(width: 8),
                          Text("Grid", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.cyanColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // العنوان على الجنب
                Text("Sign Up", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.mainTextColor)),
                const SizedBox(height: 10),
                // الجملة الوصفية في النص
                Center(
                  child: Text(
                    "Create your profile to join us",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.subTextColor, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: nameController,
                  label: "Full Name",
                  prefixIcon: Icons.person_outline,
                  validator: (value) => value!.isEmpty ? "Enter your name" : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: emailController,
                  label: "Email Address",
                  prefixIcon: Icons.email_outlined,
                  validator: (value) => value!.isEmpty ? "Enter email" : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: phoneController,
                  label: "Phone Number",
                  prefixIcon: Icons.phone_android_outlined,
                  validator: (value) => value!.length < 10 ? "Invalid phone" : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: passwordController,
                  label: "Password",
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) => value!.length < 6 ? "Short password" : null,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(color: AppColors.cyanColor))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purplecolor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: register,
                          child: const Text("Create Account", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: TextStyle(color: AppColors.subTextColor)),
                        Text("Log In", style: TextStyle(color: AppColors.cyanColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}