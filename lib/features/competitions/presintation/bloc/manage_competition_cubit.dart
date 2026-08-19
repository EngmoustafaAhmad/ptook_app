import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';
import 'manage_competition_state.dart';

class ManageCompetitionCubit extends Cubit<ManageCompetitionState> {
  final ICompetitionRepository repository;

  StreamSubscription? _competitionSubscription;
  StreamSubscription? _teamsSubscription;
  bool _isDeleting = false;

  ManageCompetitionCubit({required this.repository})
      : super(const ManageCompetitionState());

  /// Initializes state with competition data and starts real-time listeners.
  void initialize(CompetitionEntity initialCompetition) {
    _isDeleting = false;
    emit(state.copyWith(
      status: ManageCompetitionStatus.loaded,
      competition: initialCompetition,
      errorMessage: null,
      successMessage: null,
    ));

    _listenToStreams(initialCompetition.id);
  }

  /// Resets transient statuses and messages to prevent duplicate snackbars on rebuilds.
  void resetState() {
    emit(state.copyWith(
      status: state.competition != null
          ? ManageCompetitionStatus.loaded
          : ManageCompetitionStatus.initial,
      errorMessage: null,
      successMessage: null,
    ));
  }

  void _listenToStreams(String competitionId) {
    _cancelSubscriptions();

    _competitionSubscription = repository
        .streamCompetition(competitionId)
        .listen(
      (competition) {
        if (_isDeleting) return;
        emit(state.copyWith(
          status: ManageCompetitionStatus.loaded,
          competition: competition,
        ));
      },
      onError: (error) {
        if (_isDeleting || _competitionSubscription == null) return;
        emit(state.copyWith(
          status: ManageCompetitionStatus.failure,
          errorMessage: error.toString(),
        ));
      },
    );

    _teamsSubscription = repository
        .streamTeams(competitionId)
        .listen(
      (teams) {
        if (_isDeleting) return;
        emit(state.copyWith(
          status: ManageCompetitionStatus.loaded,
          teams: teams,
        ));
      },
      onError: (error) {
        if (_isDeleting || _teamsSubscription == null) return;
        emit(state.copyWith(
          status: ManageCompetitionStatus.failure,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  // ===========================================================================
  // UI & ACCORDION STATE CONTROLLERS
  // ===========================================================================

  /// Toggles expansion for a team card accordion.
  void toggleExpandTeam(String teamId) {
    emit(state.copyWith(
      expandedTeamId: state.expandedTeamId == teamId ? null : teamId,
    ));
  }

  /// Toggles viewing all teams vs top rank preview.
  void toggleShowAllTeams() {
    emit(state.copyWith(showAllTeams: !state.showAllTeams));
  }

  // ===========================================================================
  // TEAM MANAGEMENT ACTIONS
  // ===========================================================================

  /// Creates a new team under the active competition.
  Future<void> createTeam({
    required String teamName,
    bool isPrivate = false,
    String? joinCode,
  }) async {
    if (state.competition == null || teamName.trim().isEmpty) return;

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.createTeam(
      competitionId: state.competition!.id,
      name: teamName.trim(),
      isPrivate: isPrivate,
      joinCode: joinCode,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (createdTeam) => emit(state.copyWith(
        status: ManageCompetitionStatus.actionSuccess,
        expandedTeamId: createdTeam.id,
        successMessage: 'Team "${createdTeam.name}" created successfully',
      )),
    );
  }

  /// Deletes a team and cleans up accordion selection if active.
  Future<void> deleteTeam(String teamId) async {
    if (state.competition == null) return;

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.deleteTeam(
      competitionId: state.competition!.id,
      teamId: teamId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.actionSuccess,
        expandedTeamId:
            state.expandedTeamId == teamId ? null : state.expandedTeamId,
        successMessage: 'Team deleted successfully',
      )),
    );
  }

  // ===========================================================================
  // USER TEAM JOIN / LEAVE ACTIONS
  // ===========================================================================

  /// Allows the logged-in user to join a public or private team.
  Future<void> joinTeam({
    required String teamId,
    String? competitionId,
    String? joinCode,
  }) async {
    final compId = competitionId ?? state.competition?.id;
    if (compId == null) return;

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.joinTeam(
      competitionId: compId,
      teamId: teamId,
      joinCode: joinCode,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.actionSuccess,
        successMessage: 'Successfully joined the team',
      )),
    );
  }

  /// Allows the logged-in user to leave a team.
  Future<void> leaveTeam({
    required String teamId,
    String? competitionId,
  }) async {
    final compId = competitionId ?? state.competition?.id;
    if (compId == null) return;

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.leaveTeam(
      competitionId: compId,
      teamId: teamId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.actionSuccess,
        successMessage: 'Left the team',
      )),
    );
  }

  // ===========================================================================
  // PARTICIPANT ACTIONS (INDIVIDUAL)
  // ===========================================================================

  /// Updates points for an individual participant in the competition.
  Future<void> updateParticipantPoints({
    required String participantId,
    required int addedPoints,
  }) async {
    if (state.competition == null) return;

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.updateParticipantPoints(
      competitionId: state.competition!.id,
      participantId: participantId,
      addedPoints: addedPoints,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.actionSuccess,
        successMessage: 'Points updated successfully',
      )),
    );
  }

  /// Removes an individual participant from the competition.
  Future<void> removeParticipant(String participantId) async {
    if (state.competition == null) return;

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.removeParticipant(
      competitionId: state.competition!.id,
      participantId: participantId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.actionSuccess,
        successMessage: 'Participant removed successfully',
      )),
    );
  }

  // ===========================================================================
  // MEMBER & POINTS ACTIONS (TEAM-BASED)
  // ===========================================================================

  /// Removes a participant/member from a team.
  Future<void> removeMember({
    required String teamId,
    required String memberId,
    String? competitionId,
  }) async {
    final compId = competitionId ?? state.competition?.id;
    if (compId == null) return;

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.removeMember(
      competitionId: compId,
      teamId: teamId,
      memberId: memberId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.actionSuccess,
        successMessage: 'Member removed',
      )),
    );
  }

  /// Updates a participant's score by passing points delta (+/-).
  Future<void> updateMemberPoints({
    required String teamId,
    required String memberId,
    required int deltaPoints,
  }) async {
    if (state.competition == null || (state.competition?.isFinished ?? false)) return;

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.updateMemberPoints(
      competitionId: state.competition!.id,
      teamId: teamId,
      memberId: memberId,
      points: deltaPoints,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.actionSuccess,
        successMessage: 'Points updated',
      )),
    );
  }

  /// Increments points for a team member by +1.
  Future<void> incrementPoints(String teamId, ParticipantEntity member) async {
    await updateMemberPoints(
      teamId: teamId,
      memberId: member.id,
      deltaPoints: 1,
    );
  }

  /// Decrements points for a team member by -1.
  Future<void> decrementPoints(String teamId, ParticipantEntity member) async {
    await updateMemberPoints(
      teamId: teamId,
      memberId: member.id,
      deltaPoints: -1,
    );
  }

  // ===========================================================================
  // COMPETITION LIFECYCLE
  // ===========================================================================

  /// Updates details of an existing competition.
  Future<void> updateCompetition(CompetitionEntity competition) async {
    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.updateCompetition(competition);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.updated,
        competition: competition,
        successMessage: 'Competition updated successfully',
      )),
    );
  }

  /// Marks the current competition as finished/completed.
  Future<void> finishCompetition() async {
    if (state.competition == null) return;

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.finishCompetition(state.competition!.id);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.finished,
        successMessage: 'Competition finished successfully',
      )),
    );
  }

  /// Permanently deletes the competition and suppresses stream race condition errors.
  Future<void> deleteCompetition() async {
    if (state.competition == null) return;

    _isDeleting = true;
    await _cancelSubscriptions();

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.deleteCompetition(state.competition!.id);

    result.fold(
      (failure) {
        _isDeleting = false;
        emit(state.copyWith(
          status: ManageCompetitionStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.deleted,
        successMessage: 'Competition deleted successfully',
      )),
    );
  }

  /// Safe cleanup that clears references before awaiting cancellation.
  Future<void> _cancelSubscriptions() async {
    final compSub = _competitionSubscription;
    final teamsSub = _teamsSubscription;

    _competitionSubscription = null;
    _teamsSubscription = null;

    await compSub?.cancel();
    await teamsSub?.cancel();
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}