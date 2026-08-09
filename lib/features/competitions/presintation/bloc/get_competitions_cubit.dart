import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/usecases/get_competition_usecase.dart';

import '../../domain/entities/competition_entity.dart';

part 'get_competitions_state.dart';

class GetCompetitionsCubit extends Cubit<GetCompetitionsState> {
  final GetCompetitionsUseCase getCompetitionsUseCase;

  GetCompetitionsCubit({
    required this.getCompetitionsUseCase,
  }) : super(GetCompetitionsInitial());

  Future<void> fetchCompetitions() async {
    emit(GetCompetitionsLoading());

    try {
      final competitions = await getCompetitionsUseCase();
      emit(GetCompetitionsSuccess(competitions));
    } catch (e) {
      emit(GetCompetitionsError(e.toString()));
    }
  }

  /// Senior Method: Updates a single competition in the list in-memory 
  /// without triggering a full network refetch.
  void updateCompetitionInList(CompetitionEntity updatedCompetition) {
    if (state is GetCompetitionsSuccess) {
      final currentCompetitions = (state as GetCompetitionsSuccess).competitions;

      final updatedList = currentCompetitions.map((comp) {
        return comp.id == updatedCompetition.id ? updatedCompetition : comp;
      }).toList();

      emit(GetCompetitionsSuccess(updatedList));
    }
  }

  /// Senior Method: Adds a newly joined competition to the top of the list if it isn't already present.
  void addOrUpdateCompetition(CompetitionEntity competition) {
    if (state is GetCompetitionsSuccess) {
      final currentList = List<CompetitionEntity>.from(
        (state as GetCompetitionsSuccess).competitions,
      );

      final index = currentList.indexWhere((c) => c.id == competition.id);

      if (index != -1) {
        currentList[index] = competition;
      } else {
        currentList.insert(0, competition); // Add at top of list
      }

      emit(GetCompetitionsSuccess(currentList));
    }
  }
}