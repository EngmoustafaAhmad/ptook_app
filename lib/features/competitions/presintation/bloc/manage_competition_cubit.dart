import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'manage_competition_state.dart';

class ManageCompetitionCubit extends Cubit<ManageCompetitionState> {
  final ICompetitionRepository repository;

  StreamSubscription? _competitionSubscription;
  StreamSubscription? _participantsSubscription;

  ManageCompetitionCubit({required this.repository})
      : super(const ManageCompetitionState());

  /// Initializes subscriptions for real-time updates on the competition and its participants.
  void initialize(CompetitionEntity initialCompetition) {
    emit(state.copyWith(
      status: ManageCompetitionStatus.loaded,
      competition: initialCompetition,
    ));

    _listenToStreams(initialCompetition.id);
  }

  void _listenToStreams(String competitionId) {
    _competitionSubscription?.cancel();
    _participantsSubscription?.cancel();

    _competitionSubscription = repository
        .streamCompetition(competitionId)
        .listen(
      (competition) {
        emit(state.copyWith(
          status: ManageCompetitionStatus.loaded,
          competition: competition,
        ));
      },
      onError: (error) {
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
        emit(state.copyWith(
          status: ManageCompetitionStatus.loaded,
          participants: participants,
        ));
      },
      onError: (error) {
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

  /// Permanently deletes the competition.
  Future<void> deleteCompetition() async {
    if (state.competition == null) return;

    emit(state.copyWith(status: ManageCompetitionStatus.actionInProgress));

    final result = await repository.deleteCompetition(state.competition!.id);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ManageCompetitionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: ManageCompetitionStatus.deleted,
        successMessage: 'Competition deleted successfully',
      )),
    );
  }

  @override
  Future<void> close() {
    _competitionSubscription?.cancel();
    _participantsSubscription?.cancel();
    return super.close();
  }
}