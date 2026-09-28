abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashProgressState extends SplashState {
  final double progress;
  final String statusMessage;

  SplashProgressState({
    required this.progress,
    required this.statusMessage,
  });
}

class SplashUnauthenticated extends SplashState {}

class SplashAuthenticated extends SplashState {
  final String userId;
  SplashAuthenticated({required this.userId});
}