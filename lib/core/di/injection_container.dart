import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';
import 'package:ptook/features/competitions/data/datasources/competition_remote_data_source.dart';
import 'package:ptook/features/competitions/data/repositories/competition_repository_impl.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'package:ptook/features/competitions/domain/usecases/create_competition_usecase.dart';
import 'package:ptook/features/competitions/presintation/bloc/create_competition_cubit.dart';

// استيراد طبقات الـ Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart'; 

final sl = GetIt.instance;

Future<void> init() async {
  //! 1. Features - Auth
  
  // Bloc / Cubit
  sl.registerFactory(
    () => AuthCubit(
      registerUseCase: sl(), 
      loginUseCase: sl(), 
    ),
  );

  // Use cases
  // 💡 التعديل الصحيح: نمرر sl() فقط، و GetIt سيتكفل بالباقي تلقائياً!
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl())); 

  // Repository
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(auth: sl(), db: sl()),
  );

  //! 2. External (المكتبات الخارجية)
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseDatabase.instance);

  // Factory للـ Cubit (لأنه يتم إنشاؤه وتدميره مع الشاشة)
sl.registerFactory(() => CreateCompetitionCubit(createCompetitionUseCase: sl()));

// Use Case
sl.registerLazySingleton(() => CreateCompetitionUseCase(repository: sl()));

// Repository
sl.registerLazySingleton<ICompetitionRepository>(() => CompetitionRepositoryImpl(remoteDataSource: sl()));

// Data Source
sl.registerLazySingleton<ICompetitionRemoteDataSource>(() => CompetitionRemoteDataSourceImpl(database: sl()));
}