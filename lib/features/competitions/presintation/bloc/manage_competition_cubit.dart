import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'manage_competition_state.dart';

class ManageCompetitionCubit extends Cubit<ManageCompetitionState> {
  final ICompetitionRepository repository;

  StreamSubscription? _competitionSubscription;
  StreamSubscription? _participantsSubscription;
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

    _participantsSubscription = repository
        .streamParticipants(competitionId)
        .listen(
      (participants) {
        if (_isDeleting) return;
        emit(state.copyWith(
          status: ManageCompetitionStatus.loaded,
          participants: participants,
        ));
      },
      onError: (error) {
        if (_isDeleting || _participantsSubscription == null) return;
        emit(state.copyWith(
          status: ManageCompetitionStatus.failure,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  /// Increments or decrements points for a specific participant.
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

  /// Removes a participant from the competition.
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
        successMessage: 'Participant removed',
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
    final partSub = _participantsSubscription;

    _competitionSubscription = null;
    _participantsSubscription = null;

    await compSub?.cancel();
    await partSub?.cancel();
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}