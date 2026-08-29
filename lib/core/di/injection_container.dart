import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/i_manage_competition_remote_data_source.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/manage_competition_remote_data_source_impl.dart';
import 'package:ptook/features/Manage%20Competitions/data/repositories/manage_competition_repository_impl.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/i_manage_competition_repository.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/competition/delete_competition_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/competition/finish_competition_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/competition/stream_competition_manage_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/competition/update_competition_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/participant/remove_participant_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/participant/stream_participants_manage_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/participant/update_competition_participant_points_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/team/create_team_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/team/delete_team_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/team/remove_team_participant_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/team/stream_teams_manage_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/domain/usecases/team/update_team_participant_points_usecase.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_cubit.dart';
import 'package:ptook/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ptook/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ptook/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:ptook/features/auth/domain/usecases/login_usecase.dart';
import 'package:ptook/features/auth/domain/usecases/register_usecase.dart';
import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';
import 'package:ptook/features/create_competition/data/datasources/create_competition_remote_datasource_impl.dart';
import 'package:ptook/features/create_competition/data/datasources/i_create_competition_remote_datasource.dart';
import 'package:ptook/features/create_competition/data/repositories/create_competition_repository_impl.dart';
import 'package:ptook/features/create_competition/domain/repositories/i_create_competition_repository.dart';
import 'package:ptook/features/create_competition/domain/usecases/create_competition_usecase.dart';
import 'package:ptook/features/create_competition/presintation/cubits/create_competition_cubit.dart';
import 'package:ptook/features/search_competitions/data/datasources/i_search_competition_remote_data_source.dart';
import 'package:ptook/features/search_competitions/data/datasources/search_competition_remote_data_source_impl.dart';
import 'package:ptook/features/search_competitions/data/repositories/search_competition_repository_impl.dart';
import 'package:ptook/features/search_competitions/domain/repositories/i_search_competition_repository.dart';
import 'package:ptook/features/search_competitions/domain/usecases/get_created_competitions_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/get_joined_competitions_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/get_all_competitions_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/join_competition_search_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/stream_search_competitions_usecase.dart';
import 'package:ptook/features/search_competitions/presentation/cubits/search_competition_cubit.dart';
import 'package:ptook/features/shared/domain/usecase/get_competition_details_usecase.dart';
import 'package:ptook/features/view_competition/data/datasources/i_view_competition_remote_data_source.dart';
import 'package:ptook/features/view_competition/data/datasources/view_competition_remote_data_source_impl.dart';
import 'package:ptook/features/view_competition/data/repositories/view_competition_repository_impl.dart';
import 'package:ptook/features/view_competition/domain/repositories/i_view_competition_repository.dart';
import 'package:ptook/features/view_competition/domain/usecases/join_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/leave_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/stream_participants_view_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/stream_teams_view_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/team_actions_usecase.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_teams/view_teams_cubit.dart';
import 'package:ptook/services/deep_link_handler.dart';

final sl = GetIt.instance;

/// Global entry point to initialize all application dependencies.
Future<void> initDependencies() async {
  _initCoreServices();
  _initAuthFeature();
  _initSearchCompetitionFeature();
  _initManageCompetitionFeature();
  _initViewCompetitionFeature();
  _initCreateCompetitionFeature();
}

// =============================================================================
// HELPER METHODS
// =============================================================================

/// Safe registration helper for Lazy Singletons to prevent duplicate errors.
void _registerLazySingleton<T extends Object>(T Function() factoryFunc) {
  if (!sl.isRegistered<T>()) {
    sl.registerLazySingleton<T>(factoryFunc);
  }
}

/// Safe registration helper for Factories to prevent duplicate errors.
void _registerFactory<T extends Object>(T Function() factoryFunc) {
  if (!sl.isRegistered<T>()) {
    sl.registerFactory<T>(factoryFunc);
  }
}

// =============================================================================
// CORE HANDLERS & SERVICES
// =============================================================================
void _initCoreServices() {
  _registerLazySingleton<DeepLinkHandler>(() => DeepLinkHandler());
  _registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  _registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
}

// =============================================================================
// AUTH FEATURE
// =============================================================================
void _initAuthFeature() {
  // Data Source
  _registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
      firebaseAuth: sl<FirebaseAuth>(),
    ),
  );

  // Repository
  _registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<IAuthRemoteDataSource>(),
    ),
  );

  // Use Cases
  _registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<IAuthRepository>()),
  );
  _registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<IAuthRepository>()),
  );

  // Cubits
  _registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
    ),
  );
}

// =============================================================================
// SEARCH COMPETITIONS FEATURE
// =============================================================================
void _initSearchCompetitionFeature() {
  // Data Source
  _registerLazySingleton<ISearchCompetitionRemoteDataSource>(
    () => SearchCompetitionRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Repository
  _registerLazySingleton<ISearchCompetitionRepository>(
    () => SearchCompetitionRepositoryImpl(
      sl<ISearchCompetitionRemoteDataSource>(),
    ),
  );

  // Use Cases
  _registerLazySingleton<StreamPublicCompetitionsUseCase>(
    () => StreamPublicCompetitionsUseCase(
      sl<ISearchCompetitionRepository>(),
    ),
  );
  _registerLazySingleton<StreamSearchCompetitionsUseCase>(
    () => StreamSearchCompetitionsUseCase(
      sl<ISearchCompetitionRepository>(),
    ),
  );
  _registerLazySingleton<StreamJoinedCompetitionsUseCase>(
    () => StreamJoinedCompetitionsUseCase(
      sl<ISearchCompetitionRepository>(),
    ),
  );
  _registerLazySingleton<StreamCreatedCompetitionsUseCase>(
    () => StreamCreatedCompetitionsUseCase(
      sl<ISearchCompetitionRepository>(),
    ),
  );
  _registerLazySingleton<JoinCompetitionSearchUseCase>(
    () => JoinCompetitionSearchUseCase(
      sl<ISearchCompetitionRepository>(),
    ),
  );

  // Cubit
  _registerFactory<SearchCompetitionCubit>(
    () => SearchCompetitionCubit(
      streamPublicCompetitionsUseCase: sl<StreamPublicCompetitionsUseCase>(),
      streamSearchCompetitionsUseCase:
          sl<StreamSearchCompetitionsUseCase>(),
      streamJoinedCompetitionsUseCase: sl<StreamJoinedCompetitionsUseCase>(),
      streamCreatedCompetitionsUseCase: sl<StreamCreatedCompetitionsUseCase>(),
      joinCompetitionSearchUseCase: sl<JoinCompetitionSearchUseCase>(),
    ),
  );
}

// =============================================================================
// MANAGE COMPETITIONS FEATURE
// =============================================================================
void _initManageCompetitionFeature() {
  // Data Source
  _registerLazySingleton<IManageCompetitionRemoteDataSource>(
    () => ManageCompetitionRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Repository
  _registerLazySingleton<IManageCompetitionRepository>(
    () => ManageCompetitionRepositoryImpl(
      sl<IManageCompetitionRemoteDataSource>(),
    ),
  );

  // Use Cases - Competition
  _registerLazySingleton<StreamCompetitionManageUseCase>(
    () => StreamCompetitionManageUseCase(sl<IManageCompetitionRepository>()),
  );
  _registerLazySingleton<UpdateCompetitionUseCase>(
    () => UpdateCompetitionUseCase(sl<IManageCompetitionRepository>()),
  );
  _registerLazySingleton<FinishCompetitionUseCase>(
    () => FinishCompetitionUseCase(sl<IManageCompetitionRepository>()),
  );
  _registerLazySingleton<DeleteCompetitionUseCase>(
    () => DeleteCompetitionUseCase(sl<IManageCompetitionRepository>()),
  );

  // Use Cases - Participant
  _registerLazySingleton<StreamParticipantsManageUseCase>(
    () => StreamParticipantsManageUseCase(sl<IManageCompetitionRepository>()),
  );

  _registerLazySingleton<RemoveParticipantUseCase>(
    () => RemoveParticipantUseCase(sl<IManageCompetitionRepository>()),
  );

  // Use Cases - Team
  _registerLazySingleton<StreamTeamsManageUseCase>(
    () => StreamTeamsManageUseCase(sl<IManageCompetitionRepository>()),
  );
  _registerLazySingleton<CreateTeamUseCase>(
    () => CreateTeamUseCase(sl<IManageCompetitionRepository>()),
  );
  _registerLazySingleton<DeleteTeamUseCase>(
    () => DeleteTeamUseCase(sl<IManageCompetitionRepository>()),
  );
  _registerLazySingleton<UpdateCompetitoinParticipantPointsUseCase>(
    () => UpdateCompetitoinParticipantPointsUseCase(sl<IManageCompetitionRepository>()),
  );
  _registerLazySingleton<UpdateTeamParticipantPointsUseCase>(
    () => UpdateTeamParticipantPointsUseCase(sl<IManageCompetitionRepository>()),
  );
  _registerLazySingleton<RemoveTeamParticipantUseCase>(
    () => RemoveTeamParticipantUseCase(sl<IManageCompetitionRepository>()),
  );

  // Cubits
  _registerFactory<ManageCompetitionCubit>(
    () => ManageCompetitionCubit(
      streamCompetitionManageUseCase: sl<StreamCompetitionManageUseCase>(),
      updateCompetitionUseCase: sl<UpdateCompetitionUseCase>(),
      finishCompetitionUseCase: sl<FinishCompetitionUseCase>(),
      deleteCompetitionUseCase: sl<DeleteCompetitionUseCase>(),
    ),
  );

  _registerFactory<ParticipantManagementCubit>(
    () => ParticipantManagementCubit(
      streamParticipantsUseCase: sl<StreamParticipantsManageUseCase>(),
      removeParticipantUseCase: sl<RemoveParticipantUseCase>(), 
      updateCompetitoinParticipantPointsUseCase: sl<UpdateCompetitoinParticipantPointsUseCase>(),
    ),
  );

  _registerFactory<TeamManagementCubit>(
    () => TeamManagementCubit(
      streamTeamsUseCase: sl<StreamTeamsManageUseCase>(),
      createTeamUseCase: sl<CreateTeamUseCase>(),
      deleteTeamUseCase: sl<DeleteTeamUseCase>(), 
      updateTeamParticipantPointsUseCase: sl<UpdateTeamParticipantPointsUseCase>(), 
      removeTeamParticipantUseCase: sl<RemoveTeamParticipantUseCase>(),
    ),
  );
}

// =============================================================================
// VIEW COMPETITION FEATURE
// =============================================================================
void _initViewCompetitionFeature() {
  // Data Source
  _registerLazySingleton<IViewCompetitionRemoteDataSource>(
    () => ViewCompetitionRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Repository
  _registerLazySingleton<IViewCompetitionRepository>(
    () => ViewCompetitionRepositoryImpl(
      sl<IViewCompetitionRemoteDataSource>(),
    ),
  );

  // Use Cases - Competition & Spectating
  _registerLazySingleton<StreamParticipantsViewUseCase>(
    () => StreamParticipantsViewUseCase(sl<IViewCompetitionRepository>()),
  );
  _registerLazySingleton<StreamTeamsViewUseCase>(
    () => StreamTeamsViewUseCase(sl<IViewCompetitionRepository>()),
  );
  _registerLazySingleton<GetCompetitionDetailsUseCase>(
    () => GetCompetitionDetailsUseCase(sl<IViewCompetitionRepository>()),
  );
  _registerLazySingleton<JoinCompetitionUseCase>(
    () => JoinCompetitionUseCase(sl<IViewCompetitionRepository>()),
  );
  _registerLazySingleton<LeaveCompetitionUseCase>(
    () => LeaveCompetitionUseCase(sl<IViewCompetitionRepository>()),
  );

  // Use Cases - Team Actions
  _registerLazySingleton<JoinTeamUseCase>(
    () => JoinTeamUseCase(sl<IViewCompetitionRepository>()),
  );
  _registerLazySingleton<LeaveTeamUseCase>(
    () => LeaveTeamUseCase(sl<IViewCompetitionRepository>()),
  );
  _registerLazySingleton<SwitchTeamUseCase>(
    () => SwitchTeamUseCase(sl<IViewCompetitionRepository>()),
  );

  // Cubits
  _registerFactory<ViewParticipantsCubit>(
    () => ViewParticipantsCubit(
      streamParticipantsViewUseCase: sl<StreamParticipantsViewUseCase>(),
      joinCompetitionUseCase: sl<JoinCompetitionUseCase>(),
      leaveCompetitionUseCase: sl<LeaveCompetitionUseCase>(),
      joinTeamUseCase: sl<JoinTeamUseCase>(),
      leaveTeamUseCase: sl<LeaveTeamUseCase>(), 
      switchTeamUseCase: sl<SwitchTeamUseCase>(),
    ),
  );

  _registerFactory<ViewTeamsCubit>(
    () => ViewTeamsCubit(
      streamTeamsUseCase: sl<StreamTeamsViewUseCase>(),
    ),
  );

  _registerFactory<CompetitionHomeCubit>(
    () => CompetitionHomeCubit(
      streamParticipantsViewUseCase: sl<StreamParticipantsViewUseCase>(),
      getCompetitionDetailsUseCase: sl<GetCompetitionDetailsUseCase>(),
      joinCompetitionUseCase: sl<JoinCompetitionUseCase>(),
    ),
  );
}

// =============================================================================
// CREATE COMPETITION FEATURE
// =============================================================================
void _initCreateCompetitionFeature() {
  // Data Source
  _registerLazySingleton<ICreateCompetitionRemoteDataSource>(
    () => CreateCompetitionRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Repository
  _registerLazySingleton<ICreateCompetitionRepository>(
    () => CreateCompetitionRepositoryImpl(
      remoteDataSource: sl<ICreateCompetitionRemoteDataSource>(),
    ),
  );

  // Use Cases
  _registerLazySingleton<CreateCompetitionUseCase>(
    () => CreateCompetitionUseCase(
      sl<ICreateCompetitionRepository>(),
    ),
  );

  // Cubit
  _registerFactory<CreateCompetitionCubit>(
    () => CreateCompetitionCubit(
      createCompetitionUseCase: sl<CreateCompetitionUseCase>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
}