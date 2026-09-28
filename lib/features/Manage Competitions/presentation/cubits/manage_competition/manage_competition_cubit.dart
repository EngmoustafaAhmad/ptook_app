import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/domain/entities/competition_entity.dart';
import '../../../domain/usecases/competition/delete_competition_usecase.dart';
import '../../../domain/usecases/competition/finish_competition_usecase.dart';
import '../../../domain/usecases/competition/stream_competition_manage_usecase.dart';
import '../../../domain/usecases/competition/update_competition_usecase.dart';
import 'manage_competition_state.dart';

class ManageCompetitionCubit extends Cubit<ManageCompetitionState> {
  final StreamCompetitionManageUseCase _streamCompetitionUseCase;
  final UpdateCompetitionUseCase _updateCompetitionUseCase;
  final FinishCompetitionUseCase _finishCompetitionUseCase;
  final DeleteCompetitionUseCase _deleteCompetitionUseCase;

  StreamSubscription<CompetitionEntity?>? _competitionSubscription;

  ManageCompetitionCubit({
    required StreamCompetitionManageUseCase streamCompetitionManageUseCase,
    required UpdateCompetitionUseCase updateCompetitionUseCase,
    required FinishCompetitionUseCase finishCompetitionUseCase,
    required DeleteCompetitionUseCase deleteCompetitionUseCase,
  })  : _streamCompetitionUseCase = streamCompetitionManageUseCase,
        _updateCompetitionUseCase = updateCompetitionUseCase,
        _finishCompetitionUseCase = finishCompetitionUseCase,
        _deleteCompetitionUseCase = deleteCompetitionUseCase,
        super(const ManageCompetitionInitial());

  /// Initializes state with competition data and starts real-time streaming silently
  void initialize(CompetitionEntity competition) {
    _safeEmit(ManageCompetitionLoaded(competition: competition));
    // Start streaming without showing a full loading screen since we already have data
    _listenToCompetitionStream(competition.id);
  }

  /// Public method to stream with explicit loading state (e.g., manual refresh)
  void streamCompetition(String competitionId) {
    _safeEmit(ManageCompetitionLoading(competition: state.competition));
    _listenToCompetitionStream(competitionId);
  }

  void _listenToCompetitionStream(String competitionId) {
    _competitionSubscription?.cancel();
    _competitionSubscription = _streamCompetitionUseCase(competitionId).listen(
      (competition) => _safeEmit(ManageCompetitionLoaded(competition: competition)),
      onError: (error) => _safeEmit(
        ManageCompetitionFailure(error.toString(), competition: state.competition),
      ),
    );
  }

  Future<void> updateCompetition(CompetitionEntity competition) async {
    _safeEmit(ManageCompetitionLoading(competition: state.competition));
    final result = await _updateCompetitionUseCase(competition);
    
    result.when(
      onSuccess: (_) {
        _safeEmit(ManageCompetitionActionSuccess(
          'Competition updated successfully',
          competition: competition,
        ));
      },
      onFailure: (failure) {
        _safeEmit(ManageCompetitionFailure(failure.message, competition: state.competition));
      },
    );
  }

  Future<void> finishCompetition([String? competitionId]) async {
    final targetId = competitionId ?? state.competition?.id;
    if (targetId == null) return;

    _safeEmit(ManageCompetitionLoading(competition: state.competition));
    final result = await _finishCompetitionUseCase(targetId);
    
    result.when(
      onSuccess: (_) {
        _safeEmit(ManageCompetitionFinished(
          message: 'Competition finished successfully',
          competition: state.competition,
        ));
      },
      onFailure: (failure) {
        _safeEmit(ManageCompetitionFailure(failure.message, competition: state.competition));
      },
    );
  }

  Future<void> deleteCompetition([String? competitionId]) async {
    final targetId = competitionId ?? state.competition?.id;
    if (targetId == null) return;

    _safeEmit(ManageCompetitionLoading(competition: state.competition));
    final result = await _deleteCompetitionUseCase(targetId);
    
    result.when(
      onSuccess: (_) {
        _safeEmit(const ManageCompetitionDeleted(
          message: 'Competition deleted successfully',
        ));
      },
      onFailure: (failure) {
        _safeEmit(ManageCompetitionFailure(failure.message, competition: state.competition));
      },
    );
  }

  void resetState() => _safeEmit(const ManageCompetitionInitial());

  void _safeEmit(ManageCompetitionState newState) {
    if (!isClosed) emit(newState);
  }

  @override
  Future<void> close() {
    _competitionSubscription?.cancel();
    return super.close();
  }
}