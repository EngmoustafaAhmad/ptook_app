
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/activity/domain/entities/activity_entity.dart';
import 'package:ptook/features/activity/domain/repositories/i_activity_repository.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/view_competition/domain/usecases/join_individual_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/join_team_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/leave_individual_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/leave_team_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/stream_participants_view_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/team_actions_usecase.dart';
import 'view_participants_state.dart';

class ViewParticipantsCubit extends Cubit<ViewParticipantsState> {
  final StreamParticipantsViewUseCase _streamParticipantsViewUseCase;
  final JoinIndividualCompetitionUseCase _joinIndividualCompetitionUseCase;
  final JoinTeamCompetitionUseCase _joinTeamCompetitionUseCase;
  final LeaveIndividualCompetitionUseCase _leaveIndividualCompetitionUseCase;
  final LeaveTeamCompetitionUseCase _leaveTeamCompetitionUseCase;
  final JoinTeamUseCase _joinTeamUseCase;
  final LeaveTeamUseCase _leaveTeamUseCase;
  final IActivityRepository _activityRepository;

  StreamSubscription<List<ParticipantEntity>>? _participantsSubscription;
  List<ParticipantEntity> _lastCachedParticipants = [];

  ViewParticipantsCubit({
    required StreamParticipantsViewUseCase streamParticipantsViewUseCase,
    required JoinIndividualCompetitionUseCase joinIndividualCompetitionUseCase,
    required JoinTeamCompetitionUseCase joinTeamCompetitionUseCase,
    required LeaveIndividualCompetitionUseCase leaveIndividualCompetitionUseCase,
    required LeaveTeamCompetitionUseCase leaveTeamCompetitionUseCase,
    required JoinTeamUseCase joinTeamUseCase,
    required LeaveTeamUseCase leaveTeamUseCase,
    required IActivityRepository activityRepository,
  })  : _streamParticipantsViewUseCase = streamParticipantsViewUseCase,
        _joinIndividualCompetitionUseCase = joinIndividualCompetitionUseCase,
        _joinTeamCompetitionUseCase = joinTeamCompetitionUseCase,
        _leaveIndividualCompetitionUseCase = leaveIndividualCompetitionUseCase,
        _leaveTeamCompetitionUseCase = leaveTeamCompetitionUseCase,
        _joinTeamUseCase = joinTeamUseCase,
        _leaveTeamUseCase = leaveTeamUseCase,
        _activityRepository = activityRepository,
        super(ViewParticipantsInitial());

  void listenToParticipants(String competitionId) {
    if (isClosed) return;
    
    // Only set loading if we don't already have an active listener
    if (_participantsSubscription == null) {
      _safeEmit(ViewParticipantsLoading());
    }

    _participantsSubscription?.cancel();
    _participantsSubscription = _streamParticipantsViewUseCase(competitionId).listen(
      (participants) {
        _lastCachedParticipants = List.unmodifiable(participants);
        _safeEmit(ViewParticipantsLoaded(_lastCachedParticipants));
      },
      onError: (error) {
        _safeEmit(ViewParticipantsError(error.toString()));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // COMPETITION-LEVEL ACTIONS
  // ---------------------------------------------------------------------------

  Future<void> joinIndividualCompetition({
    required String competitionId,
    required String userId,
  }) async {
    _safeEmit(ViewParticipantsActionLoading());
    final result = await _joinIndividualCompetitionUseCase(competitionId);
    _handleJoinResult(
      result: result,
      successMessage: 'Successfully joined competition!',
      competitionId: competitionId,
      userId: userId,
      activityTitle: 'Joined Competition 🏆',
      activityDescription: 'Joined competition as an individual participant.',
    );
  }

  Future<void> leaveIndividualCompetition({
    required String competitionId,
    required String userId,
  }) async {
    _safeEmit(ViewParticipantsActionLoading());
    final result = await _leaveIndividualCompetitionUseCase(competitionId);
    _handleLeaveResult(
      result: result,
      successMessage: 'Left the competition successfully.',
      competitionId: competitionId,
      userId: userId,
      activityTitle: 'Left Competition 🚪',
      activityDescription: 'Left the individual competition.',
      activityType: ActivityType.competitionLeft, // Updated
    );
  }

  Future<void> joinTeamCompetition({
    required String competitionId,
    required String userId,
  }) async {
    _safeEmit(ViewParticipantsActionLoading());
    final result = await _joinTeamCompetitionUseCase(competitionId);
    _handleJoinResult(
      result: result,
      successMessage: 'Successfully joined team competition!',
      competitionId: competitionId,
      userId: userId,
      activityTitle: 'Joined Competition Roster 🏆',
      activityDescription: 'Joined the team competition roster.',
    );
  }

  Future<void> leaveTeamCompetition({
    required String competitionId,
    required String userId,
  }) async {
    _safeEmit(ViewParticipantsActionLoading());
    final result = await _leaveTeamCompetitionUseCase(competitionId);
    _handleLeaveResult(
      result: result,
      successMessage: 'Left team competition successfully.',
      competitionId: competitionId,
      userId: userId,
      activityTitle: 'Left Team Competition 🚪',
      activityDescription: 'Left the team competition.',
      activityType: ActivityType.competitionLeft, // Updated
    );
  }

  // ---------------------------------------------------------------------------
  // TEAM-LEVEL ACTIONS
  // ---------------------------------------------------------------------------

  Future<void> joinTeam({
    required String competitionId,
    required String teamId,
    required String userId,
    String? joinCode,
  }) async {
    _safeEmit(ViewParticipantsActionLoading());
    final result = await _joinTeamUseCase(
      competitionId: competitionId,
      teamId: teamId,
      joinCode: joinCode,
    );
    _handleJoinResult(
      result: result,
      successMessage: 'Successfully joined team!',
      competitionId: competitionId,
      userId: userId,
      activityTitle: 'Joined Team 🛡️',
      activityDescription: 'Joined a team in the competition.',
    );
  }

  Future<void> leaveTeam({
    required String competitionId,
    required String teamId,
    required String userId,
  }) async {
    _safeEmit(ViewParticipantsActionLoading());
    final result = await _leaveTeamUseCase(
      competitionId: competitionId,
      teamId: teamId,
    );
    _handleLeaveResult(
      result: result,
      successMessage: 'Left team successfully.',
      competitionId: competitionId,
      userId: userId,
      activityTitle: 'Left Team 🚪',
      activityDescription: 'Left your current team.',
      activityType: ActivityType.competitionLeft, // Updated
    );
  }

  // ---------------------------------------------------------------------------
  // RESULT & ACTIVITY LOG HANDLERS
  // ---------------------------------------------------------------------------

  void _handleJoinResult({
    required Result<void> result,
    required String successMessage,
    required String competitionId,
    required String userId,
    required String activityTitle,
    required String activityDescription,
    ActivityType activityType = ActivityType.competitionJoined,
  }) {
    result.when(
      onSuccess: (_) {
        _logActivity(
          userId: userId,
          title: activityTitle,
          description: activityDescription,
          type: activityType,
          competitionId: competitionId,
        );
        _safeEmit(JoinCompetitionSuccess(successMessage));
        _restorePreviousState();
      },
      onFailure: (failure) {
        _safeEmit(ViewParticipantsError(failure.message));
        _restorePreviousState();
      },
    );
  }

  void _handleLeaveResult({
    required Result<void> result,
    required String successMessage,
    required String competitionId,
    required String userId,
    required String activityTitle,
    required String activityDescription,
    required ActivityType activityType,
  }) {
    result.when(
      onSuccess: (_) {
        _logActivity(
          userId: userId,
          title: activityTitle,
          description: activityDescription,
          type: activityType,
          competitionId: competitionId,
        );
        _safeEmit(LeaveCompetitionSuccess(successMessage));
        _restorePreviousState();
      },
      onFailure: (failure) {
        _safeEmit(ViewParticipantsError(failure.message));
        _restorePreviousState();
      },
    );
  }

  void _logActivity({
    required String userId,
    required String title,
    required String description,
    required ActivityType type,
    required String competitionId,
  }) {
    _activityRepository.logActivity(
      ActivityEntity(
        id: '',
        userId: userId,
        title: title,
        description: description,
        type: type,
        timestamp: DateTime.now(),
        competitionId: competitionId,
      ),
    );
  }

  void _restorePreviousState() {
    // If the stream is active, restore the loaded state using cached data 
    // without tearing down and re-subscribing to the stream.
    if (_lastCachedParticipants.isNotEmpty) {
      _safeEmit(ViewParticipantsLoaded(_lastCachedParticipants));
    }
  }

  void _safeEmit(ViewParticipantsState newState) {
    if (!isClosed) emit(newState);
  }

  @override
  Future<void> close() {
    _participantsSubscription?.cancel();
    return super.close();
  }
}