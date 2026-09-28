import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_cubit.dart';
import 'package:ptook/features/splash/presintation/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final ProfileCubit profileCubit;

  SplashCubit({required this.profileCubit}) : super(SplashInitial());

  Future<void> initializeApp() async {
    try {
      // Step 1: Engine Warmup
      emit(SplashProgressState(progress: 0.15, statusMessage: "Starting Ptook..."));
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 2: Check Firebase Auth Session
      emit(SplashProgressState(progress: 0.40, statusMessage: "Checking authentication..."));
      final currentUser = FirebaseAuth.instance.currentUser;
      await Future.delayed(const Duration(milliseconds: 300));

      if (currentUser == null) {
        emit(SplashProgressState(progress: 1.0, statusMessage: "Ready"));
        await Future.delayed(const Duration(milliseconds: 200));
        emit(SplashUnauthenticated());
        return;
      }

      // Step 3: Stream Active User Profile Data
      emit(SplashProgressState(progress: 0.75, statusMessage: "Fetching user profile..."));
      profileCubit.loadUserProfile(currentUser.uid);
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 4: Finalizing Setup
      emit(SplashProgressState(progress: 1.0, statusMessage: "Ready!"));
      await Future.delayed(const Duration(milliseconds: 200));
      emit(SplashAuthenticated(userId: currentUser.uid));
    } catch (e) {
      // Fallback on error to LoginView
      emit(SplashUnauthenticated());
    }
  }
}