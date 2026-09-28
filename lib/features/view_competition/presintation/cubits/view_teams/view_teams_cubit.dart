import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import 'package:ptook/features/view_competition/domain/usecases/stream_teams_view_usecase.dart';
import 'view_teams_state.dart';

class ViewTeamsCubit extends Cubit<ViewTeamsState> {
  final StreamTeamsViewUseCase _streamTeamsUseCase;
  StreamSubscription<List<TeamEntity>>? _teamsSubscription;

  ViewTeamsCubit({
    required StreamTeamsViewUseCase streamTeamsUseCase,
  })  : _streamTeamsUseCase = streamTeamsUseCase,
        super(ViewTeamsInitial());

  void streamTeams(String competitionId) {
    if (isClosed) return;
    emit(ViewTeamsLoading());

    _teamsSubscription?.cancel();
    _teamsSubscription = _streamTeamsUseCase(competitionId).listen(
      (teams) {
        if (!isClosed) {
          emit(ViewTeamsLoaded(List.unmodifiable(teams)));
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(ViewTeamsError(error.toString()));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _teamsSubscription?.cancel();
    return super.close();
  }
}