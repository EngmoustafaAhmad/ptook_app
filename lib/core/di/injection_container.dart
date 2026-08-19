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
import 'package:ptook/features/competitions/data/datasources/competition_remote_data_source_impl.dart';
import 'package:ptook/features/competitions/data/datasources/i_competition_remote_data_source.dart';
import 'package:ptook/features/competitions/data/repositories/competition_repository_impl.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'package:ptook/features/competitions/domain/usecases/create_competition_usecase.dart';
import 'package:ptook/features/competitions/domain/usecases/get_competition_bycode_usecase.dart';
import 'package:ptook/features/competitions/domain/usecases/get_created_competitions_usecase.dart';
import 'package:ptook/features/competitions/domain/usecases/get_joined_competitions_usecase.dart';
import 'package:ptook/features/competitions/domain/usecases/get_public_competitions_usecase.dart';
import 'package:ptook/features/competitions/domain/usecases/search_public_competitions_usecase.dart';
import 'package:ptook/features/competitions/domain/usecases/switch_team_use_case.dart';
import 'package:ptook/features/competitions/presintation/bloc/competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/create_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/search_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/team_cubit.dart';

// =========================
// PARTICIPANTS FEATURE IMPORTS
// =========================
import 'package:ptook/features/participants/data/datasources/participant_remote_data_source.dart';
import 'package:ptook/features/participants/data/datasources/participant_remote_data_source_impl.dart';
import 'package:ptook/features/participants/data/repositories/participant_repository_impl.dart';
import 'package:ptook/features/participants/domain/repositories/i_participant_repository.dart';
import 'package:ptook/features/participants/domain/usecases/assign_podium_stars_usecase.dart';
import 'package:ptook/features/participants/domain/usecases/get_competition_participants_usecase.dart';
import 'package:ptook/features/participants/domain/usecases/join_competition_usecase.dart';
import 'package:ptook/features/participants/domain/usecases/leave_competition_usecase.dart';
import 'package:ptook/features/participants/domain/usecases/update_participant_points_usecase.dart';
import 'package:ptook/features/participants/presintation/bloc/join_competition_cubit.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_cubit.dart';

// =========================
// SERVICES IMPORTS
// =========================
import 'package:ptook/services/deep_link_handler.dart';

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
  //! Services
  //! =========================

  sl.registerLazySingleton<DeepLinkHandler>(
    () => DeepLinkHandler(),
  );

  //! =========================
  //! AUTH FEATURE
  //! =========================

  // 1. Data Sources
  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl(),
      firestore: sl(),
    ),
  );

  // 2. Repositories
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // 3. Use Cases
  sl.registerLazySingleton(
    () => RegisterUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => LoginUseCase(sl()),
  );

  // 4. Cubits
  sl.registerFactory(
    () => AuthCubit(
      registerUseCase: sl(),
      loginUseCase: sl(),
    ),
  );

  //! =========================
  //! COMPETITIONS FEATURE
  //! =========================

  // 1. Data Sources
  sl.registerLazySingleton<ICompetitionRemoteDataSource>(
    () => CompetitionRemoteDataSourceImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );

  // 2. Repositories
  sl.registerLazySingleton<ICompetitionRepository>(
    () => CompetitionRepositoryImpl(
      sl<ICompetitionRemoteDataSource>(),
    ),
  );

  // 3. Use Cases
  sl.registerLazySingleton(
    () => CreateCompetitionUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => SearchPublicCompetitionsUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => GetPublicCompetitionsUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => GetCompetitionByCodeUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => GetJoinedCompetitionsUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => GetCreatedCompetitionsUseCase(sl()),
  );

  // 4. Cubits
  sl.registerFactory(
    () => CompetitionCubit(sl()),
  );

  sl.registerFactory(
    () => CreateCompetitionCubit(
      createCompetitionUseCase: sl(),
      auth: sl(),
    ),
  );

  sl.registerFactory(
    () => SearchCompetitionCubit(
      getPublicCompetitionsUseCase: sl(),
      searchPublicCompetitionsUseCase: sl(),
      getJoinedCompetitionsUseCase: sl(),
      getCreatedCompetitionsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ManageCompetitionCubit(
      repository: sl<ICompetitionRepository>(),
    ),
  );

  // Use Case
  sl.registerLazySingleton(() => SwitchTeamUseCase(sl()));
  // Cubit
  sl.registerFactory(() => TeamCubit(
      repository: sl(),
      switchTeamUseCase: sl(),
    ));

  //! =========================
  //! PARTICIPANTS FEATURE
  //! =========================

  // 1. Data Sources
  sl.registerLazySingleton<IParticipantRemoteDataSource>(
    () => ParticipantRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  // 2. Repositories
  sl.registerLazySingleton<IParticipantRepository>(
    () => ParticipantRepositoryImpl(
      remoteDataSource: sl<IParticipantRemoteDataSource>(),
    ),
  );

  // 3. Use Cases
  sl.registerLazySingleton<JoinCompetitionUseCase>(
    () => JoinCompetitionUseCase(sl<IParticipantRepository>()),
  );

  sl.registerLazySingleton<LeaveCompetitionUseCase>(
    () => LeaveCompetitionUseCase(sl<IParticipantRepository>()),
  );

  sl.registerLazySingleton<GetCompetitionParticipantsUseCase>(
    () => GetCompetitionParticipantsUseCase(sl<IParticipantRepository>()),
  );

  sl.registerLazySingleton<UpdatePointsUseCase>(
    () => UpdatePointsUseCase(sl<IParticipantRepository>()),
  );

  sl.registerLazySingleton<AssignPodiumStarsUseCase>(
    () => AssignPodiumStarsUseCase(sl<IParticipantRepository>()),
  );

  // 4. Cubits
  sl.registerFactory<ParticipantCubit>(
    () => ParticipantCubit(
      joinCompetitionUseCase: sl<JoinCompetitionUseCase>(),
      leaveCompetitionUseCase: sl<LeaveCompetitionUseCase>(),
      getCompetitionParticipantsUseCase: sl<GetCompetitionParticipantsUseCase>(),
      updatePointsUseCase: sl<UpdatePointsUseCase>(),
      assignPodiumStarsUseCase: sl<AssignPodiumStarsUseCase>(),
    ),
  );

  sl.registerFactory<JoinCompetitionCubit>(
    () => JoinCompetitionCubit(
      joinCompetitionUseCase: sl<JoinCompetitionUseCase>(),
      auth: sl<FirebaseAuth>(),
      leaveCompetitionUseCase: sl<LeaveCompetitionUseCase>(),
    ),
  );
}