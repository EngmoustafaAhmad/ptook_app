// features/auth/presintation/views/forget_password_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/Theme/app_text_styles.dart';
import 'package:ptook/core/extentions/context_extentions.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';
import 'package:ptook/features/auth/presintation/cubit/auth_state.dart';
import 'package:ptook/features/auth/presintation/widgets/auth_text_field.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Smart width scaling for Web UX
    final double maxContentWidth =
        MediaQuery.of(context).size.width > 600 ? 450 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSuccess) {
            context.showSuccess(state.message);
            Navigator.pop(context);
          } else if (state is AuthError) {
            context.showError(state.message);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: maxContentWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.primary,
                          size: 56,
                        ),
                        16.vs,
                        Text("Reset Password",
                            style: AppTextStyles.displayLarge),
                        8.vs,
                        Text(
                          "Enter the email address associated with your account\nand we'll send you a link to reset your password.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary),
                        ),
                        32.vs,
                        Container(
                          padding: 24.padAll,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                                  final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return "Please enter a valid email address";
                                  }
                                  return null;
                                },
                              ),
                              24.vs,
                              ElevatedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : _onResetSubmitted,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.background,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
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
                                        "Send Reset Link",
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
                            Text("Remembered your password? ",
                                style: AppTextStyles.bodyMedium),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
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

  void _onResetSubmitted() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(
            email: _emailController.text.trim(),
          );
    }
  }
}