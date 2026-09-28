import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/usecase/get_competition_details_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/get_favorite_competitions_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/is_favorite_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/stream_participants_view_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/toggle_favorite_usecase.dart';
import 'competition_home_state.dart';

class CompetitionHomeCubit extends Cubit<CompetitionHomeState> {
  final StreamParticipantsViewUseCase _streamParticipantsViewUseCase;
  final GetCompetitionDetailsUseCase _getCompetitionDetailsUseCase;
  final ToggleFavoriteUsecase _toggleFavoriteUseCase;
  final IsFavoriteUseCase _isFavoriteUseCase;
  final GetFavoriteCompetitionsUsecase _getFavoriteCompetitionsUseCase;

  StreamSubscription<List<ParticipantEntity>>? _participantsSubscription;

  CompetitionHomeCubit({
    required StreamParticipantsViewUseCase streamParticipantsViewUseCase,
    required GetCompetitionDetailsUseCase getCompetitionDetailsUseCase,
    required ToggleFavoriteUsecase toggleFavoriteUseCase,
    required IsFavoriteUseCase isFavoriteUseCase,
    required GetFavoriteCompetitionsUsecase getFavoriteCompetitionsUseCase,
  })  : _streamParticipantsViewUseCase = streamParticipantsViewUseCase,
        _getCompetitionDetailsUseCase = getCompetitionDetailsUseCase,
        _toggleFavoriteUseCase = toggleFavoriteUseCase,
        _isFavoriteUseCase = isFavoriteUseCase,
        _getFavoriteCompetitionsUseCase = getFavoriteCompetitionsUseCase,
        super(const CompetitionHomeInitial());

  /// Initializes real-time listener and verifies favorite state with backend
  Future<void> loadCompetitionData({
    required CompetitionEntity competition,
    required String userId,
  }) async {
    _safeEmit(const CompetitionHomeLoading());

    // 1. Fetch favorite status
    bool initialFavState = competition.isFavorite;
    final favResult = await _isFavoriteUseCase(
      userId: userId,
      competitionId: competition.id,
    );

    if (favResult is Success<bool>) {
      initialFavState = favResult.data;
    }

    final initialComp = competition.copyWith(isFavorite: initialFavState);

    // 2. Immediate baseline state emission so UI opens without blocking on stream sync
    _safeEmit(
      CompetitionHomeLoaded(
        competition: initialComp,
        participants: const [],
        isFavorite: initialFavState,
      ),
    );

    // 3. Unsubscribe non-blocking and bind stream
    _participantsSubscription?.cancel();
    _participantsSubscription =
        _streamParticipantsViewUseCase(competition.id).listen(
      (participants) {
        final currentState = state;

        final currentIsFav = currentState is CompetitionHomeLoaded
            ? currentState.isFavorite
            : initialFavState;

        final currentComp = currentState is CompetitionHomeLoaded
            ? currentState.competition.copyWith(isFavorite: currentIsFav)
            : initialComp;

        _safeEmit(
          CompetitionHomeLoaded(
            competition: currentComp,
            participants: participants,
            isFavorite: currentIsFav,
          ),
        );
      },
      onError: (error) {
        _safeEmit(CompetitionHomeError(error.toString()));
      },
    );
  }

  /// Fetches saved/favorited competitions list for the current user
  Future<void> fetchSavedCompetitions({
    required String userId,
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    _safeEmit(const CompetitionHomeLoading());

    final result = await _getFavoriteCompetitionsUseCase(
      userId: userId,
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );

    result.when(
      onSuccess: (competitions) =>
          _safeEmit(SavedCompetitionsLoaded(competitions: competitions)),
      onFailure: (failure) =>
          _safeEmit(CompetitionHomeError(failure.message)),
    );
  }

  /// Fetches full competition details and checks favorite status
  Future<void> fetchCompetitionDetails({
    required String competitionId,
    required String userId,
  }) async {
    _safeEmit(const CompetitionHomeLoading());

    final result = await _getCompetitionDetailsUseCase(
      competitionId: competitionId,
      userId: userId,
    );

    result.when(
      onSuccess: (competition) async {
        await loadCompetitionData(
          competition: competition,
          userId: userId,
        );
      },
      onFailure: (failure) {
        _safeEmit(CompetitionHomeError(failure.message));
      },
    );
  }

  /// Toggles favorite status with an optimistic state update
  Future<void> toggleFavorite({
    required String userId,
    required CompetitionEntity competition,
  }) async {
    if (state is SavedCompetitionsLoaded) {
      final currentState = state as SavedCompetitionsLoaded;
      final newIsFavorite = !competition.isFavorite;

      final updatedList = currentState.competitions
          .where((item) => item.id != competition.id)
          .toList();

      _safeEmit(SavedCompetitionsLoaded(competitions: updatedList));

      final result = await _toggleFavoriteUseCase(
        userId: userId,
        competitionId: competition.id,
        isFavorite: newIsFavorite,
      );

      if (result is Err) {
        await fetchSavedCompetitions(userId: userId);
        _safeEmit(CompetitionHomeError(result.message));
      }
      return;
    }

    if (state is! CompetitionHomeLoaded) return;

    final currentState = state as CompetitionHomeLoaded;
    final previousIsFavorite = currentState.isFavorite;
    final newIsFavorite = !previousIsFavorite;

    final updatedCompetition = currentState.competition.copyWith(
      isFavorite: newIsFavorite,
    );

    _safeEmit(
      currentState.copyWith(
        competition: updatedCompetition,
        isFavorite: newIsFavorite,
      ),
    );

    final result = await _toggleFavoriteUseCase(
      userId: userId,
      competitionId: competition.id,
      isFavorite: newIsFavorite,
    );

    if (result is Err) {
      final rolledBackCompetition = currentState.competition.copyWith(
        isFavorite: previousIsFavorite,
      );

      _safeEmit(
        currentState.copyWith(
          competition: rolledBackCompetition,
          isFavorite: previousIsFavorite,
        ),
      );
      _safeEmit(CompetitionHomeError(result.message));
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