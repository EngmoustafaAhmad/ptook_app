// features/auth/presintation/views/register_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/app_scaffold.dart'; // 💡 استيراد الـ AppScaffold للدخول المباشر عند نجاح التسجيل
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/Theme/app_text_styles.dart';
import 'package:ptook/core/extentions/context_extentions.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';
import 'package:ptook/features/auth/presintation/cubit/auth_state.dart';
import 'package:ptook/features/auth/presintation/views/login_view.dart';
import 'package:ptook/features/auth/presintation/widgets/auth_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تحديد عرض مخصص ليتناسق التصميم بشكل احترافي على شاشات المتصفح الكبيرة (Chrome Web) والموبايل
    final double maxContentWidth = MediaQuery.of(context).size.width > 600 ? 450 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.showSuccess('Welcome to Ptook!');
            
            // 💡 الأفضل للمستخدم (UX): نقله مباشرة إلى الـ AppScaffold الرئيسي بعد إنشاء الحساب فوراً دون إجباره على تسجيل الدخول مرة أخرى
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
            child: Center( // تمركز المحتوى في وسط الشاشة للويب والموبايل التابلت
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: SizedBox(
                  width: maxContentWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt, 
                          color: AppColors.primary, 
                          size: 56,
                        ),
                        16.vs,
                        
                        Text("Start Your Journey", style: AppTextStyles.displayLarge),
                        8.vs,
                        
                        Text(
                          "Create an account to track your points\nand compete with friends.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        32.vs,
                        
                        // تصميم الـ Container مع تأثير ظل حركي وحواف ناعمة
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 📝 حقل الاسم الكامل
                              AuthTextField(
                                label: "Full Name",
                                hintText: "e.g. John Doe",
                                prefixIcon: Icons.person_outline,
                                controller: _nameController,
                                validator: (value) => (value == null || value.trim().isEmpty) ? "Name cannot be empty" : null,
                              ),
                              16.vs,
                              
                              // 📝 حقل البريد الإلكتروني مع التحقق الذكي (Regex)
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
                              
                              // 📝 حقل كلمة المرور
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
                              
                              // 📝 حقل تأكيد كلمة المرور ومطابقتها برمجياً مع الحقل السابق
                              AuthTextField(
                                label: "Confirm Password",
                                hintText: "••••••••",
                                prefixIcon: Icons.verified_user_outlined,
                                isPassword: _obscurePassword,
                                controller: _confirmPasswordController,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return "Passwords do not match";
                                  }
                                  return null;
                                },
                              ),
                              24.vs,
                              
                              // 🎯 تصميم زر التسجيل الاحترافي مع استجابة لحالة التحميل
                              ElevatedButton(
                                onPressed: state is AuthLoading ? null : _onRegisterSubmitted,
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
                                        "Register",
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
                        
                        // 🔄 رابط العودة السلس لشاشة الدخول (Login)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? ", style: AppTextStyles.bodyMedium),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginView()),
                                );
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  "Login",
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

  void _onRegisterSubmitted() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().registerUser(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            name: _nameController.text.trim(),
          );
    }
  }
}