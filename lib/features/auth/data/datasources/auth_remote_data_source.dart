import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ptook/features/auth/data/models/user_model.dart';

abstract class IAuthRemoteDataSource {
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  });

  // 💡 الدالة المحدثة لتسجيل الدخول الآمن والمشترك
  Future<UserModel> login({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseDatabase db;

  AuthRemoteDataSourceImpl({required this.auth, required this.db});

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    // 1. إنشاء الحساب في Auth
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userModel = UserModel(
      uid: credential.user!.uid,
      email: email,
      name: name,
      points: 0,
    );

    // 2. حفظ البيانات في Realtime Database
    await db.ref('users/${userModel.uid}').set(userModel.toJson());

    return userModel;
  }

  // 💡 تنفيذ دالة تسجيل الدخول القوية والمرنة للـ Web والـ Mobile معاً
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // 1. التحقق من البريد وكلمة المرور عبر Firebase Auth
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    // 2. استخدام once() بدلاً من get() لتجنب تعليق الويب اللانهائي
    final event = await db.ref('users/$uid').once();
    final snapshot = event.snapshot;

    if (snapshot.exists && snapshot.value != null) {
      // 🛠️ الحل الجذري: حلقة تكرار مرنة (Flexible Loop) لتفريغ البيانات
      // تحل أزمة تعليق كاش المتصفح وأخطاء الـ Type Casting على الموبايل صامتاً
      final Map<String, dynamic> cleanData = {};
      
      if (snapshot.value is Map) {
        final Map<dynamic, dynamic> rawMap = snapshot.value as Map<dynamic, dynamic>;
        rawMap.forEach((key, value) {
          cleanData[key.toString()] = value;
        });
      }
      
      return UserModel.fromJson(cleanData);
    } else {
      // خطوة أمان احتياطية: إذا لم توجد بيانات بالداتابيز، ننشئ كائن بالبيانات الأساسية المتوفرة
      return UserModel(
        uid: uid,
        email: email,
        name: credential.user!.displayName ?? "User",
        points: 0,
      );
    }
  }
}