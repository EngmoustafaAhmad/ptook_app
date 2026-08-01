import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';

import 'package:ptook/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ptook/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ptook/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:ptook/features/auth/domain/usecases/register_usecase.dart';
import 'package:ptook/features/auth/domain/usecases/login_usecase.dart';

import 'package:ptook/features/competitions/data/datasources/competition_remote_data_source.dart';
import 'package:ptook/features/competitions/data/repositories/competition_repository_impl.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'package:ptook/features/competitions/domain/usecases/create_competition_usecase.dart';
import 'package:ptook/features/competitions/domain/usecases/get_public_competitions_usecase.dart';
import 'package:ptook/features/competitions/domain/usecases/search_public_competitions_usecase.dart';
import 'package:ptook/features/competitions/presintation/bloc/create_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/search_competition_cubit.dart';


final sl = GetIt.instance;


Future<void> init() async {


  //! =========================
  //! External Dependencies
  //! =========================

  sl.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );


  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );



  //! =========================
  //! AUTH FEATURE
  //! =========================


  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      registerUseCase: sl(),
      loginUseCase: sl(),
    ),
  );


  // Use Cases
  sl.registerLazySingleton(
    () => RegisterUseCase(sl()),
  );


  sl.registerLazySingleton(
    () => LoginUseCase(sl()),
  );



  // Repository
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );



  // Data Source
  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl(),
      firestore: sl(),
    ),
  );



  //! =========================
  //! COMPETITIONS FEATURE
  //! =========================


  // Cubit
  sl.registerFactory(
  () => CreateCompetitionCubit(
    createCompetitionUseCase: sl(),
    auth: sl(),
  ),
);



  // Use Case
  sl.registerLazySingleton(
    () => CreateCompetitionUseCase(
      repository: sl(),
    ),
  );



  // Repository
  sl.registerLazySingleton<ICompetitionRepository>(
    () => CompetitionRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );



  // Data Source
  sl.registerLazySingleton<ICompetitionRemoteDataSource>(
    () => CompetitionRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // Search Competition UseCase
  sl.registerLazySingleton(
    () => SearchPublicCompetitionsUseCase(
      repository: sl(),
    ),
  );

  sl.registerFactory(
  () => SearchCompetitionCubit(
    searchPublicCompetitionsUseCase: sl(),
  ),
);

}