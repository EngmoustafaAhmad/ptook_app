import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/usecases/get_competition_usecase.dart';

part 'get_competitions_state.dart';

class GetCompetitionsCubit extends Cubit<GetCompetitionsState> {
  final GetCompetitionsUseCase getCompetitionsUseCase;

  GetCompetitionsCubit({
    required this.getCompetitionsUseCase,
  }) : super(GetCompetitionsInitial());

  Future<void> fetchCompetitions() async {
    emit(GetCompetitionsLoading());

    final result = await getCompetitionsUseCase();

    result.fold(
      (failure) => emit(GetCompetitionsError(failure.message)),
      (competitions) => emit(GetCompetitionsSuccess(competitions)),
    );
  }

  /// Senior Method: Updates a single competition in the list in-memory 
  /// without triggering a full network refetch.
  void updateCompetitionInList(CompetitionEntity updatedCompetition) {
    final currentState = state;
    if (currentState is GetCompetitionsSuccess) {
      final updatedList = currentState.competitions.map((comp) {
        return comp.id == updatedCompetition.id ? updatedCompetition : comp;
      }).toList();

      emit(GetCompetitionsSuccess(updatedList));
    }
  }

  /// Senior Method: Adds a newly joined competition to the top of the list if it isn't already present.
  void addOrUpdateCompetition(CompetitionEntity competition) {
    final currentState = state;
    if (currentState is GetCompetitionsSuccess) {
      final currentList = List<CompetitionEntity>.from(currentState.competitions);

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