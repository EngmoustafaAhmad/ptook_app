import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/competitions/i_manage_competition_remote_data_source.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/competitions/manage_competition_remote_data_source_impl.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/participants/i_manage_participant_remote_data_source.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/participants/manage_participant_remote_data_source_impl.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/teams/i_manage_team_remote_data_source.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/teams/manage_team_remote_data_source_impl.dart';
import 'package:ptook/features/Manage%20Competitions/data/repositories/competition/manage_competition_repository_impl.dart';
import 'package:ptook/features/Manage%20Competitions/data/repositories/participant/manage_participant_repository_impl.dart';
import 'package:ptook/features/Manage%20Competitions/data/repositories/team/manage_team_repository_impl.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/competition/i_manage_competition_repository.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/participant/i_manage_participant_repository.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/team/i_manage_team_repository.dart';
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
import 'package:ptook/features/activity/data/datasources/activity_remote_data_source_impl.dart';
import 'package:ptook/features/activity/data/datasources/i_activity_remote_data_source.dart';
import 'package:ptook/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:ptook/features/activity/domain/repositories/i_activity_repository.dart';
import 'package:ptook/features/activity/domain/usecases/stream_user_activities_usecase.dart';
import 'package:ptook/features/activity/presintation/cubit/activity_cubit.dart';
import 'package:ptook/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ptook/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ptook/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:ptook/features/auth/domain/usecases/login_usecase.dart';
import 'package:ptook/features/auth/domain/usecases/register_usecase.dart';
import 'package:ptook/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:ptook/features/auth/presintation/cubit/auth_cubit.dart';
import 'package:ptook/features/create_competition/data/datasources/create_competition_remote_datasource_impl.dart';
import 'package:ptook/features/create_competition/data/datasources/i_create_competition_remote_datasource.dart';
import 'package:ptook/features/create_competition/data/repositories/create_competition_repository_impl.dart';
import 'package:ptook/features/create_competition/domain/repositories/i_create_competition_repository.dart';
import 'package:ptook/features/create_competition/domain/usecases/create_competition_usecase.dart';
import 'package:ptook/features/create_competition/domain/usecases/upload_competition_image_usecase.dart';
import 'package:ptook/features/create_competition/presintation/cubits/create_competition_cubit.dart';
import 'package:ptook/features/profile/data/datasources/i_profile_remote_data_source.dart';
import 'package:ptook/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:ptook/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ptook/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:ptook/features/profile/domain/usecases/stream_user_profile_usecase.dart';
import 'package:ptook/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:ptook/features/profile/domain/usecases/upload_profile_avatar_usecase.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_cubit.dart';
import 'package:ptook/features/profile/presintation/cubit/update_profile/update_profile_cubit.dart';
import 'package:ptook/features/search_competitions/data/datasources/i_search_competition_remote_data_source.dart';
import 'package:ptook/features/search_competitions/data/datasources/search_competition_remote_data_source_impl.dart';
import 'package:ptook/features/search_competitions/data/repositories/search_competition_repository_impl.dart';
import 'package:ptook/features/search_competitions/domain/repositories/i_search_competition_repository.dart';
import 'package:ptook/features/search_competitions/domain/usecases/search_active_competitions_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/stream_active_competitions_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/sync_owner_competition_usecase.dart';
import 'package:ptook/features/search_competitions/presentation/cubits/search_competition_cubit.dart';
import 'package:ptook/features/shared/domain/usecase/get_competition_details_usecase.dart';
import 'package:ptook/features/view_competition/data/datasources/competition/i_view_competition_remote_data_source.dart';
import 'package:ptook/features/view_competition/data/datasources/competition/view_competition_remote_data_source_impl.dart';
import 'package:ptook/features/view_competition/data/repositories/team/view_team_repository_impl.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_cubit.dart';
import 'package:ptook/features/view_competition/data/datasources/participant/i_view_participant_remote_data_source.dart';
import 'package:ptook/features/view_competition/data/datasources/participant/view_participant_remote_data_source_impl.dart';
import 'package:ptook/features/view_competition/data/datasources/team/i_view_team_reamote_data_source.dart';
import 'package:ptook/features/view_competition/data/datasources/team/view_team_remote_data_source_impl.dart';
import 'package:ptook/features/view_competition/data/repositories/competition/view_competition_repository_impl.dart';
import 'package:ptook/features/view_competition/data/repositories/participant/view_participant_repository_impl.dart';
import 'package:ptook/features/view_competition/domain/repositories/competition/i_view_competition_repository.dart';
import 'package:ptook/features/view_competition/domain/repositories/participant/i_view_participant_repository.dart';
import 'package:ptook/features/view_competition/domain/repositories/team/i_view_team_repository.dart';
import 'package:ptook/features/view_competition/domain/usecases/get_favorite_competitions_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/is_favorite_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/leave_team_competition_usecase.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_teams/view_teams_cubit.dart';
import 'package:ptook/features/view_competition/domain/usecases/join_individual_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/join_team_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/leave_individual_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/stream_participants_view_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/stream_teams_view_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/team_actions_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/toggle_favorite_usecase.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/services/deep_link_handler.dart';
import 'package:ptook/services/github_storage_service.dart';
import 'package:ptook/services/reward_ad_service.dart'; // ⚡ Rewarded Ad Service import

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

void _registerLazySingleton<T extends Object>(T Function() factoryFunc) {
  if (!sl.isRegistered<T>()) {
    sl.registerLazySingleton<T>(factoryFunc);
  }
}

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
  _registerLazySingleton<RewardAdService>(() => RewardAdService()); // ⚡ Registered inside GetIt
  _registerLazySingleton<GithubStorageService>(() => GithubStorageService(token: ''));
}

// =============================================================================
// AUTH FEATURE
// =============================================================================
void _initAuthFeature() {
  _registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  _registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<IAuthRemoteDataSource>(),
    ),
  );

  _registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<IAuthRepository>()),
  );
  _registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<IAuthRepository>()),
  );

  sl.registerLazySingleton<SendPasswordResetUseCase>(
    () => SendPasswordResetUseCase(sl()),
  );

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      registerUseCase: sl<RegisterUseCase>(),
      loginUseCase: sl<LoginUseCase>(),
      sendPasswordResetUseCase: sl<SendPasswordResetUseCase>(),
    ),
  );
}

// =============================================================================
// SEARCH COMPETITIONS FEATURE
// =============================================================================
void _initSearchCompetitionFeature() {
  _registerLazySingleton<ISearchCompetitionRemoteDataSource>(
    () => SearchCompetitionRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  _registerLazySingleton<ISearchCompetitionRepository>(
    () => SearchCompetitionRepositoryImpl(
      sl<ISearchCompetitionRemoteDataSource>(),
    ),
  );

  _registerLazySingleton<SearchActiveCompetitionsUseCase>(
    () => SearchActiveCompetitionsUseCase(
      sl<ISearchCompetitionRepository>(),
    ),
  );
  _registerLazySingleton<StreamActiveCompetitionsUseCase>(
    () => StreamActiveCompetitionsUseCase(
      sl<ISearchCompetitionRepository>(),
    ),
  );

  _registerFactory<SearchCompetitionCubit>(
    () => SearchCompetitionCubit(
      streamActiveCompetitionsUseCase: sl<StreamActiveCompetitionsUseCase>(), 
      searchActiveCompetitionsUseCase: sl<SearchActiveCompetitionsUseCase>(), 
      currentUserId: sl<FirebaseAuth>().currentUser?.uid ?? '',
    ),
  );
}

// =============================================================================
// MANAGE COMPETITIONS FEATURE
// =============================================================================
void _initManageCompetitionFeature() {
  _registerLazySingleton<IManageCompetitionRemoteDataSource>(
    () => ManageCompetitionRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  _registerLazySingleton<IManageParticipantRemoteDataSource>(
    () => ManageParticipantRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  _registerLazySingleton<IManageTeamRemoteDataSource>(
    () => ManageTeamRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  _registerLazySingleton<IManageCompetitionRepository>(
    () => ManageCompetitionRepositoryImpl(
      sl<IManageCompetitionRemoteDataSource>(),
    ),
  );

  _registerLazySingleton<IManageParticipantRepository>(
    () => ManageParticipantRepositoryImpl(
      sl<IManageParticipantRemoteDataSource>(),
    ),
  );

  _registerLazySingleton<IManageTeamRepository>(
    () => ManageTeamRepositoryImpl(
      sl<IManageTeamRemoteDataSource>(),
    ),
  );

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

  _registerLazySingleton<StreamParticipantsManageUseCase>(
    () => StreamParticipantsManageUseCase(sl<IManageParticipantRepository>()),
  );

  _registerLazySingleton<RemoveParticipantUseCase>(
    () => RemoveParticipantUseCase(sl<IManageParticipantRepository>()),
  );

  _registerLazySingleton<StreamTeamsManageUseCase>(
    () => StreamTeamsManageUseCase(sl<IManageTeamRepository>()),
  );
  _registerLazySingleton<CreateTeamUseCase>(
    () => CreateTeamUseCase(sl<IManageTeamRepository>()),
  );
  _registerLazySingleton<DeleteTeamUseCase>(
    () => DeleteTeamUseCase(sl<IManageTeamRepository>()),
  );
  _registerLazySingleton<UpdateCompetitoinParticipantPointsUseCase>(
    () => UpdateCompetitoinParticipantPointsUseCase(sl<IManageParticipantRepository>()),
  );
  _registerLazySingleton<UpdateTeamParticipantPointsUseCase>(
    () => UpdateTeamParticipantPointsUseCase(sl<IManageTeamRepository>()),
  );
  _registerLazySingleton<RemoveTeamParticipantUseCase>(
    () => RemoveTeamParticipantUseCase(sl<IManageTeamRepository>()),
  );

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
  _registerLazySingleton<IViewCompetitionRemoteDataSource>(
    () => ViewCompetitionRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  _registerLazySingleton<IViewTeamReamoteDataSource>(
    () => ViewTeamRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  _registerLazySingleton<IViewParticipantRemoteDataSource>(
    () => ViewParticipantRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  _registerLazySingleton<IViewCompetitionRepository>(
    () => ViewCompetitionRepositoryImpl(
      sl<IViewCompetitionRemoteDataSource>(),
    ),
  );

  _registerLazySingleton<IViewTeamRepository>(
    () => ViewTeamRepositoryImpl(
      sl<IViewTeamReamoteDataSource>(), 
    ),
  );

  _registerLazySingleton<IViewParticipantRepository>(
    () => ViewParticipantRepositoryImpl(
      sl<IViewParticipantRemoteDataSource>(),
    ),
  );

  _registerLazySingleton<ToggleFavoriteUsecase>(
    () => ToggleFavoriteUsecase(sl<IViewCompetitionRepository>()),
  );
  _registerLazySingleton<StreamParticipantsViewUseCase>(
    () => StreamParticipantsViewUseCase(sl<IViewParticipantRepository>()),
  );
  _registerLazySingleton<StreamTeamsViewUseCase>(
    () => StreamTeamsViewUseCase(sl<IViewTeamRepository>()),
  );
  _registerLazySingleton<GetCompetitionDetailsUseCase>(
    () => GetCompetitionDetailsUseCase(sl<IViewCompetitionRepository>()),
  );
  _registerLazySingleton<JoinIndividualCompetitionUseCase>(
    () => JoinIndividualCompetitionUseCase(sl<IViewParticipantRepository>()),
  );
  _registerLazySingleton<JoinTeamCompetitionUseCase>(
    () => JoinTeamCompetitionUseCase(sl<IViewTeamRepository>()),
  );
  _registerLazySingleton<JoinTeamUseCase>(
    () => JoinTeamUseCase(sl<IViewTeamRepository>()),
  );
  _registerLazySingleton<LeaveTeamUseCase>(
    () => LeaveTeamUseCase(sl<IViewTeamRepository>()),
  );
  _registerLazySingleton<IsFavoriteUseCase>(
    () => IsFavoriteUseCase(sl<IViewCompetitionRepository>()),
  );
  _registerLazySingleton<GetFavoriteCompetitionsUsecase>(
    () => GetFavoriteCompetitionsUsecase(sl<IViewCompetitionRepository>()),
  );
  _registerLazySingleton<LeaveIndividualCompetitionUseCase>(
    () => LeaveIndividualCompetitionUseCase(sl<IViewParticipantRepository>()),
  );
  _registerLazySingleton<LeaveTeamCompetitionUseCase>(
    () => LeaveTeamCompetitionUseCase(sl<IViewTeamRepository>()),
  );

  _registerFactory<ViewParticipantsCubit>(
    () => ViewParticipantsCubit(
      streamParticipantsViewUseCase: sl<StreamParticipantsViewUseCase>(),
      joinIndividualCompetitionUseCase: sl<JoinIndividualCompetitionUseCase>(),
      joinTeamUseCase: sl<JoinTeamUseCase>(),
      leaveTeamUseCase: sl<LeaveTeamUseCase>(), 
      joinTeamCompetitionUseCase: sl<JoinTeamCompetitionUseCase>(), 
      leaveIndividualCompetitionUseCase: sl<LeaveIndividualCompetitionUseCase>(), 
      leaveTeamCompetitionUseCase: sl<LeaveTeamCompetitionUseCase>(),
      activityRepository: sl<IActivityRepository>(), // ⚡ Inject Activity Repository
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
      toggleFavoriteUseCase: sl<ToggleFavoriteUsecase>(), 
      isFavoriteUseCase: sl<IsFavoriteUseCase>(), 
      getFavoriteCompetitionsUseCase: sl<GetFavoriteCompetitionsUsecase>(),
    ),
  );
}

// =============================================================================
// CREATE COMPETITION FEATURE
// =============================================================================
void _initCreateCompetitionFeature() {
  _registerLazySingleton<ICreateCompetitionRemoteDataSource>(
    () => CreateCompetitionRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  _registerLazySingleton<ICreateCompetitionRepository>(
    () => CreateCompetitionRepositoryImpl(
      remoteDataSource: sl<ICreateCompetitionRemoteDataSource>(),
    ),
  );

  _registerLazySingleton<CreateCompetitionUseCase>(
    () => CreateCompetitionUseCase(
      sl<ICreateCompetitionRepository>(),
    ),
  );

  _registerLazySingleton<UploadCompetitionImageUseCase>(
    () => UploadCompetitionImageUseCase(
      sl<GithubStorageService>(),
    ),
  );

  sl.registerFactory<CreateCompetitionCubit>(
    () => CreateCompetitionCubit(
      createCompetitionUseCase: sl(),
      uploadCompetitionImageUseCase: sl(),
      auth: sl(),
    ),
  );

  //==============================================
  // Activity FEATURE
  //==============================================


  // Data Sources
sl.registerLazySingleton<IActivityRemoteDataSource>(
  () => ActivityRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
);

// Repositories
sl.registerLazySingleton<IActivityRepository>(
  () => ActivityRepositoryImpl(remoteDataSource: sl<IActivityRemoteDataSource>()),
);

// Use Cases
sl.registerLazySingleton<StreamUserActivitiesUseCase>(
  () => StreamUserActivitiesUseCase(sl<IActivityRepository>()),
);

// Cubits
sl.registerFactory<ActivityCubit>(
  () => ActivityCubit(
    streamUserActivitiesUseCase: sl<StreamUserActivitiesUseCase>(),
  ),
);

  //==============================================
  // PROFILE FEATURE
  //==============================================

  // Data Sources
  sl.registerLazySingleton<IProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      storageService: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<StreamUserProfileUseCase>(
    () => StreamUserProfileUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateUserProfileUseCase>(
    () => UpdateUserProfileUseCase(sl()),
  );
  sl.registerLazySingleton<UploadProfileAvatarUseCase>(
    () => UploadProfileAvatarUseCase(sl()),
  );
  sl.registerLazySingleton<SyncOwnerCompetitionsUseCase>(
    () => SyncOwnerCompetitionsUseCase(),
  );

  // Cubits
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      streamUserProfileUseCase: sl<StreamUserProfileUseCase>(),
    ),
  );
  sl.registerFactory<UpdateProfileCubit>(
    () => UpdateProfileCubit(
      updateUserProfileUseCase: sl<UpdateUserProfileUseCase>(),
      uploadProfileAvatarUseCase: sl<UploadProfileAvatarUseCase>(),
      syncOwnerCompetitionsUseCase: sl<SyncOwnerCompetitionsUseCase>(),
    ),
  );

  
}