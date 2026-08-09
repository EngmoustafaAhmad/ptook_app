import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// =========================
// AUTH FEATURE IMPORTS
// =========================
import 'package:ptook/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ptook/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ptook/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:ptook/features/auth/domain/usecases/login_usecase.dart';
import 'package:ptook/features/auth/domain/usecases/register_usecase.dart';
import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';

// =========================
// COMPETITIONS FEATURE IMPORTS
// =========================
import 'package:ptook/features/competitions/data/datasources/competition_remote_data_source.dart';
import 'package:ptook/features/competitions/data/repositories/competition_repository_impl.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'package:ptook/features/competitions/domain/usecases/create_competition_usecase.dart';
import 'package:ptook/features/competitions/domain/usecases/get_public_competitions_usecase.dart';
import 'package:ptook/features/competitions/domain/usecases/search_public_competitions_usecase.dart';
import 'package:ptook/features/competitions/presintation/bloc/create_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/search_competition_cubit.dart';

// =========================
// TEAMS FEATURE IMPORTS
// =========================
import 'package:ptook/features/competitions/data/datasources/team_remote_data_source.dart';


// =========================
// PARTICIPANTS FEATURE IMPORTS
// =========================
import 'package:ptook/features/participants/data/datasources/participant_remote_data_source.dart';
import 'package:ptook/features/participants/data/datasources/participant_remote_data_source_impl.dart';
import 'package:ptook/features/participants/data/repositories/participant_repository_impl.dart';
import 'package:ptook/features/participants/domain/repositories/i_participant_repository.dart';
import 'package:ptook/features/participants/domain/usecases/join_competition_usecase.dart';
import 'package:ptook/features/participants/domain/usecases/leave_competition_usecase.dart';
import 'package:ptook/features/participants/presintation/bloc/join_competition_cubit.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_cubit.dart';

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

  // Cubits
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

  // Repositories
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl(),
      firestore: sl(),
    ),
  );

  //! =========================
  //! COMPETITIONS FEATURE
  //! =========================

  // Cubits
  sl.registerFactory(
    () => CreateCompetitionCubit(
      createCompetitionUseCase: sl(),
      auth: sl(),
    ),
  );

  sl.registerFactory(
    () => SearchCompetitionCubit(
      searchPublicCompetitionsUseCase: sl(),
    ),
  );

  // Use Cases (FIXED: Positional arguments used instead of named `repository:`)
  sl.registerLazySingleton(
    () => CreateCompetitionUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => SearchPublicCompetitionsUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => GetPublicCompetitionsUseCase(sl()),
  );

  // Repositories
  sl.registerLazySingleton<ICompetitionRepository>(
    () => CompetitionRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<ICompetitionRemoteDataSource>(
    () => CompetitionRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  //! =========================
  //! PARTICIPANTS FEATURE
  //! =========================

  // Cubits
  sl.registerFactory<JoinCompetitionCubit>(
    () => JoinCompetitionCubit(
      joinCompetitionUseCase: sl<JoinCompetitionUseCase>(),
      auth: sl<FirebaseAuth>(),
      leaveCompetitionUseCase: sl<LeaveCompetitionUseCase>(),
    ),
  );

  // Use Cases (FIXED: Removed invalid `IParticipantRepository: null`)
  sl.registerLazySingleton<JoinCompetitionUseCase>(
    () => JoinCompetitionUseCase(
      sl<IParticipantRepository>(),
    ),
  );

  sl.registerLazySingleton<LeaveCompetitionUseCase>(
    () => LeaveCompetitionUseCase(
      sl<IParticipantRepository>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<IParticipantRepository>(
    () => ParticipantRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<IParticipantRemoteDataSource>(
    () => ParticipantRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  sl.registerFactory(
    () => ParticipantCubit(
      joinCompetitionUseCase: sl(),
      leaveCompetitionUseCase: sl(),
    ),
  );
  //! =========================
  //! TEAMS FEATURE
  //! =========================

  // // Use Cases (FIXED: Positional arguments used for team use cases as well if needed)
  // sl.registerLazySingleton(
  //   () => CreateTeamUseCase(
  //     sl(),
  //   ),
  // );

  // sl.registerLazySingleton(
  //   () => GetTeamsUseCase(
  //     sl(),
  //   ),
  // );

  // // Repositories
  // sl.registerLazySingleton<ITeamRepository>(
  //   () => TeamRepositoryImpl(
  //     remoteDataSource: sl(),
  //   ),
  // );

  // Data Sources
  sl.registerLazySingleton<ITeamRemoteDataSource>(
    () => TeamRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );
}