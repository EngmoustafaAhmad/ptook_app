import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/utils/result.dart';

import '../../../domain/usecases/participant/remove_participant_usecase.dart';
import '../../../domain/usecases/participant/stream_participants_manage_usecase.dart';
import '../../../domain/usecases/participant/update_competition_participant_points_usecase.dart';
import 'participant_management_state.dart';

class ParticipantManagementCubit extends Cubit<ParticipantManagementState> {
  final StreamParticipantsManageUseCase _streamParticipantsUseCase;
  final UpdateCompetitoinParticipantPointsUseCase _updateCompetitoinParticipantPointsUseCase;
  final RemoveParticipantUseCase _removeParticipantUseCase;

  StreamSubscription? _participantsSubscription;

  ParticipantManagementCubit({
    required StreamParticipantsManageUseCase streamParticipantsUseCase,
    required UpdateCompetitoinParticipantPointsUseCase updateCompetitoinParticipantPointsUseCase,
    required RemoveParticipantUseCase removeParticipantUseCase,
  })  : _streamParticipantsUseCase = streamParticipantsUseCase,
        _updateCompetitoinParticipantPointsUseCase = updateCompetitoinParticipantPointsUseCase,
        _removeParticipantUseCase = removeParticipantUseCase,
        super(const ParticipantManagementInitial());

  void listenToParticipants(String competitionId) {
    _safeEmit(ParticipantManagementLoading(participants: state.participants));
    _participantsSubscription?.cancel();
    _participantsSubscription = _streamParticipantsUseCase(competitionId).listen(
      (participants) => _safeEmit(ParticipantManagementLoaded(participants: participants)),
      onError: (error) => _safeEmit(
        ParticipantManagementFailure(error.toString(), participants: state.participants),
      ),
    );
  }

  /// Removes a participant directly from the overall competition
  Future<void> removeParticipant({
    required String competitionId,
    required String participantId,
  }) async {
    _safeEmit(ParticipantManagementLoading(participants: state.participants));
    final result = await _removeParticipantUseCase(
      competitionId: competitionId,
      participantId: participantId,
    );

    switch (result) {
      case Success():
        _safeEmit(ParticipantActionSuccess(
          'Participant removed from competition',
          participants: state.participants,
        ));
      case Failure(:final message):
        _safeEmit(ParticipantManagementFailure(message, participants: state.participants));
    }
  }

  Future<void> updateParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  }) async {
    // Guard against empty document paths
    if (competitionId.trim().isEmpty || participantId.trim().isEmpty) {
      _safeEmit(ParticipantManagementFailure(
        'Invalid ID: competitionId or participantId cannot be empty.',
        participants: state.participants,
      ));
      return;
    }

    final result = await _updateCompetitoinParticipantPointsUseCase(
      competitionId: competitionId,
      participantId: participantId,
      addedPoints: addedPoints,
    );

    switch (result) {
      case Success():
        _safeEmit(ParticipantActionSuccess('Points updated', participants: state.participants));
      case Failure(:final message):
        _safeEmit(ParticipantManagementFailure(message, participants: state.participants));
    }
  }

  void _safeEmit(ParticipantManagementState newState) {
    if (!isClosed) emit(newState);
  }

  @override
  Future<void> close() {
    _participantsSubscription?.cancel();
    return super.close();
  }
}