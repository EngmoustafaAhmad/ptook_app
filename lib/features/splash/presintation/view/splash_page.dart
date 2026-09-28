import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ptook/app_scaffold.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/auth/presintation/views/login_view.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_cubit.dart';
import 'package:ptook/features/splash/presintation/cubit/splash_cubit.dart';
import 'package:ptook/features/splash/presintation/cubit/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGold = Color(0xFFFFC107);

    return BlocProvider<SplashCubit>(
      create: (_) {
        FlutterNativeSplash.remove();
        return SplashCubit(profileCubit: sl<ProfileCubit>())..initializeApp();
      },
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashUnauthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginView()),
            );
          } else if (state is SplashAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AppScaffold(userId: state.userId),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: BlocBuilder<SplashCubit, SplashState>(
              builder: (context, state) {
                double progress = 1.0;
                String statusText = "Ready!";

                if (state is SplashInitial) {
                  progress = 0.0;
                  statusText = "Initializing...";
                } else if (state is SplashProgressState) {
                  progress = state.progress;
                  statusText = state.statusMessage;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Center(
                    child: Column(
                      children: [
                        // 1️⃣ CENTER CONTENT: LOGO, TITLE & SLOGAN
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/ptook_icon.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Ptook',
                                style: TextStyle(
                                  color: primaryGold,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Learn. Compete. Grow.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                    
                        // 2️⃣ BOTTOM COMPACT PROGRESS BAR & STATUS
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ⚡ Small Progress Bar (180px width, 3px height)
                              SizedBox(
                                width: 180,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 3,
                                    backgroundColor: Colors.white12,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      primaryGold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                    
                              // Loading Status Text & Percentage
                              SizedBox(
                                width: 180,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      statusText,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      '${(progress * 100).round()}%',
                                      style: const TextStyle(
                                        color: primaryGold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}