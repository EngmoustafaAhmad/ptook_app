// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ptook/firebase_options.dart';

// 💡 استيراد ملف الـ GetIt بمساره الصحيح والمؤكد لديك
import 'package:ptook/core/di/injection_container.dart' as di;

// استيراد الـ Cubit والـ View
import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';
import 'package:ptook/features/auth/presintation/views/login_view.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // 🛠️ جعل GetIt يمنح الـ BlocProvider النسخة الجاهزة والمحقونة بالكامل من الـ AuthCubit
      create: (context) => di.sl<AuthCubit>(),
      child: MaterialApp(
        title: 'Ptook',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(), 
        home: const LoginView(), 
      ),
    );
  }
}