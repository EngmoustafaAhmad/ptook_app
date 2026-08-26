import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/usecase/get_competition_details_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/join_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/stream_participants_view_usecase.dart';
import 'competition_home_state.dart';

class CompetitionHomeCubit extends Cubit<CompetitionHomeState> {
  final StreamParticipantsViewUseCase _streamParticipantsViewUseCase;
  final GetCompetitionDetailsUseCase _getCompetitionDetailsUseCase;
  final JoinCompetitionUseCase _joinCompetitionUseCase;

  StreamSubscription<List<ParticipantEntity>>? _participantsSubscription;

  CompetitionHomeCubit({
    required StreamParticipantsViewUseCase streamParticipantsViewUseCase,
    required GetCompetitionDetailsUseCase getCompetitionDetailsUseCase,
    required JoinCompetitionUseCase joinCompetitionUseCase,
  })  : _streamParticipantsViewUseCase = streamParticipantsViewUseCase,
        _getCompetitionDetailsUseCase = getCompetitionDetailsUseCase,
        _joinCompetitionUseCase = joinCompetitionUseCase,
        super(const CompetitionHomeInitial());

  /// Initializes real-time listener for competition participants
  void loadCompetitionData(CompetitionEntity competition) {
    _safeEmit(const CompetitionHomeLoading());

    _participantsSubscription?.cancel();
    _participantsSubscription = _streamParticipantsViewUseCase(competition.id).listen(
      (participants) {
        _safeEmit(
          CompetitionHomeLoaded(
            competition: competition,
            participants: participants,
          ),
        );
      },
      onError: (error) {
        _safeEmit(CompetitionHomeError(error.toString()));
      },
    );
  }

  /// Fetches full competition details directly
  Future<void> fetchCompetitionDetails(String competitionId) async {
    _safeEmit(const CompetitionHomeLoading());

    final result = await _getCompetitionDetailsUseCase(competitionId);

    switch (result) {
      case Success(data: final competition):
        loadCompetitionData(competition);
      case Failure(:final message):
        _safeEmit(CompetitionHomeError(message));
    }
  }

  /// Joins competition and reloads stream context
  Future<void> joinCompetition(String competitionId) async {
    final result = await _joinCompetitionUseCase(competitionId);

    switch (result) {
      case Success():
        await fetchCompetitionDetails(competitionId);
      case Failure(:final message):
        _safeEmit(CompetitionHomeError(message));
    }
  }

  void _safeEmit(CompetitionHomeState newState) {
    if (!isClosed) emit(newState);
  }

  @override
  Future<void> close() {
    _participantsSubscription?.cancel();
    return super.close();
  }
}