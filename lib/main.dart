import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ptook/core/di/injection_container.dart' as di;
import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';
import 'package:ptook/features/auth/presintation/views/login_view.dart';
import 'package:ptook/features/splash/presintation/view/splash_page.dart';
import 'package:ptook/firebase_options.dart';
import 'package:ptook/services/deep_link_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // ⚡ Keep native splash visible until Flutter renders SplashPage
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint("Firebase initialization note: $e");
    }
  }

  await MobileAds.instance.initialize();

  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ['EMULATOR'],
    ),
  );

  await di.initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DeepLinkHandler _deepLinkHandler;

  @override
  void initState() {
    super.initState();
    _deepLinkHandler = di.sl<DeepLinkHandler>();
    _deepLinkHandler.init(navigatorKey);
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthCubit>(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Ptook',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        // ⚡ Initial entry point is SplashPage
        home: const SplashPage(),
        routes: {
          '/login': (context) => const LoginView(),
        },
      ),
    );
  }
}