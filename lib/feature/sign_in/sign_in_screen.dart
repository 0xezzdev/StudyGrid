import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_text_field.dart';
import 'package:study_grid/core/services/auth_service.dart';
import '../sign_up/sign_up_screen.dart';
import '../reset_password/reset_password_screen.dart';
import '../home/home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // لضمان بقاء العنوان على الجنب
            children: [
              const SizedBox(height: 50),
              // اللوجو والاسم في النص
              Center(
                child: Column(
                  children: [
                    Icon(Icons.grid_view_rounded, color: AppColors.cyanColor, size: 65),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Study", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.purplecolor)),
                        const SizedBox(width: 8),
                        Text("Grid", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.cyanColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // كلمة Sign In على الجنب
              Text("Sign In", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.mainTextColor)),
              const SizedBox(height: 10),
              // الجملة الوصفية في النص
              Center(
                child: Text(
                  "Welcome back! Glad to see you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.subTextColor, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: emailController,
                label: "Email Address",
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: passwordController,
                label: "Password",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordScreen())),
                  child: Text("Forgot Password?", style: TextStyle(color: AppColors.cyanColor)),
                ),
              ),
              const SizedBox(height: 30),
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
                        onPressed: login,
                        child: const Text("Log In", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: TextStyle(color: AppColors.subTextColor)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                    child: Text("Create account", style: TextStyle(color: AppColors.cyanColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}