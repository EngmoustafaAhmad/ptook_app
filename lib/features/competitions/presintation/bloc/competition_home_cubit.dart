import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/competition_repository.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';
import 'competition_home_state.dart';

class CompetitionHomeCubit extends Cubit<CompetitionHomeState> {
  final CompetitionRepository repository;
  StreamSubscription<List<ParticipantEntity>>? _participantsSubscription;

  CompetitionHomeCubit({required this.repository}) : super(CompetitionHomeInitial());

  void loadCompetitionData(CompetitionEntity competition) {
    emit(CompetitionHomeLoading());

    // Listen to live participant updates
    _participantsSubscription?.cancel();
    _participantsSubscription = repository
        .streamParticipants(competition.id)
        .listen(
      (participants) {
        emit(CompetitionHomeLoaded(
          competition: competition,
          participants: participants,
        ));
      },
      onError: (error) {
        emit(CompetitionHomeError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _participantsSubscription?.cancel();
    return super.close();
  }
}