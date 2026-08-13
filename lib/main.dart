import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ptook/features/auth/presintation/views/login_view.dart';
import 'package:ptook/firebase_options.dart';

// استيراد ملف الـ GetIt
import 'package:ptook/core/di/injection_container.dart' as di;

// استيراد الـ Cubit والـ View
import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';
import 'package:ptook/services/deep_link_handler.dart';

// 🔑 مفتاح التحكم المباشر بالتنقل (Navigator Key)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1️⃣ تهيئة فايربيز أولاً
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2️⃣ استدعاء دالة الـ GetIt لتهيئة وحقن جميع الـ UseCases والـ Cubit تلقائياً
  await di.init(); 
  
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
    // 3️⃣ تهيئة واستدعاء الـ DeepLinkHandler وتمرير الـ navigatorKey له
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
        navigatorKey: navigatorKey, // 👈 ربط الـ Key بالتطبيق
        title: 'Ptook',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const LoginView(),
      ),
    );
  }
}