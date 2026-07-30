// features/auth/presintation/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/app_scaffold.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/Theme/app_text_styles.dart';
import 'package:ptook/core/extentions/context_extentions.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';
import 'package:ptook/features/auth/presintation/cubit/auth_state.dart';
import 'package:ptook/features/auth/presintation/views/register_view.dart';
import 'package:ptook/features/auth/presintation/widgets/auth_text_field.dart';
// import 'package:ptook/features/auth/presintation/views/register_view.dart'; // قم بإلغاء التعليق عند تجهيز ملف التسجيل

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تحديد عرض مخصص للـ Card لكي يظهر بشكل متناسق ومحترفي على شاشات المتصفح الكبيرة (Chrome Web)
    final double maxContentWidth = MediaQuery.of(context).size.width > 600 ? 450 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.showSuccess('Welcome Back to Ptook!');
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AppScaffold()),
            );
          } else if (state is AuthError) {
            context.showError(state.message); 
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center( // تجعل محتوى الصفحة ممركزاً تماماً في المتصفح للـ Web UX
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: SizedBox(
                  width: maxContentWidth, // تطبيق العرض الذكي للحفاظ على تناسق الويب
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt, 
                          color: AppColors.primary, 
                          size: 56, // تكبير الأيقونة قليلاً لإعطاء هوية بصرية أقوى
                        ),
                        16.vs,
                        
                        Text("Welcome Back", style: AppTextStyles.displayLarge),
                        8.vs,
                        
                        Text(
                          "Login to continue tracking your points\nand dominating the leaderboard.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        32.vs,
                        
                        // تصميم الـ Container مع تأثير ظل خفيف (Shadow) وحواف ناعمة
                        Container(
                          padding: 24.padAll,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch, // تمدد العناصر لملء العرض المتاح للـ Button
                            children: [
                              // 📝 حقل البريد الإلكتروني مع تحقق ذكي (Email Validation)
                              AuthTextField(
                                label: "Email Address",
                                hintText: "name@example.com",
                                prefixIcon: Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Email address is required";
                                  }
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return "Please enter a valid email address";
                                  }
                                  return null;
                                },
                              ),
                              16.vs,
                              
                              // 📝 حقل كلمة المرور مع تحقق من الطول (Password Validation)
                              AuthTextField(
                                label: "Password",
                                hintText: "••••••••",
                                prefixIcon: Icons.lock_outline,
                                isPassword: _obscurePassword,
                                controller: _passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Password cannot be empty";
                                  }
                                  if (value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              16.vs,
                              
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    // هنا سيتم الانتقال لشاشة ForgetPasswordView لاحقاً
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              24.vs,
                              
                              // 🎯 تصميم زر الدخول ليكون متجاوباً وعصرياً
                              ElevatedButton(
                                onPressed: state is AuthLoading ? null : _onLoginSubmitted,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.background,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: state is AuthLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: AppColors.background,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        32.vs,
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
                            InkWell(
                              onTap: () {
                                 Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterView()),
                                );
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  "Register",
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onLoginSubmitted() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().loginUser(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }
}