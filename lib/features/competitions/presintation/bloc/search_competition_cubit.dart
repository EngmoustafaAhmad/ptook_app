import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/competition_entity.dart';
import '../../domain/usecases/search_public_competitions_usecase.dart';

part 'search_competition_state.dart';

class SearchCompetitionCubit extends Cubit<SearchCompetitionState> {
  final SearchPublicCompetitionsUseCase _searchPublicCompetitionsUseCase;

  SearchCompetitionCubit({
    required SearchPublicCompetitionsUseCase searchPublicCompetitionsUseCase,
  })  : _searchPublicCompetitionsUseCase = searchPublicCompetitionsUseCase,
        super(SearchCompetitionInitial());

  /// Executes public competition search by keyword.
  Future<void> search(String keyword) async {
    final sanitizedKeyword = keyword.trim();

    // 1. Reset state if the search term is empty
    if (sanitizedKeyword.isEmpty) {
      _safeEmit(SearchCompetitionInitial());
      return;
    }

    _safeEmit(SearchCompetitionLoading());

    try {
      final competitions = await _searchPublicCompetitionsUseCase(
        sanitizedKeyword.toLowerCase(),
      );

      _safeEmit(SearchCompetitionSuccess(competitions));
    } catch (e) {
      _safeEmit(
        SearchCompetitionError(
          _formatErrorMessage(e),
        ),
      );
    }
  }

  /// Clears search query and resets state back to Initial.
  void clearSearch() {
    _safeEmit(SearchCompetitionInitial());
  }

  /// Updates a single competition in the current list without re-fetching from backend.
  void updateCompetitionInList(CompetitionEntity updatedCompetition) {
    if (state is SearchCompetitionSuccess) {
      final currentList = (state as SearchCompetitionSuccess).competitions;

      final updatedList = currentList.map((comp) {
        return comp.id == updatedCompetition.id ? updatedCompetition : comp;
      }).toList();

      _safeEmit(SearchCompetitionSuccess(updatedList));
    }
  }

  /// Toggles or increments/decrements participant counts locally when join/leave actions occur.
  void toggleParticipationStatus({
    required String competitionId,
    required bool isJoining,
  }) {
    if (state is SearchCompetitionSuccess) {
      final currentList = (state as SearchCompetitionSuccess).competitions;

      final updatedList = currentList.map((comp) {
        if (comp.id == competitionId) {
          final newCount = isJoining
              ? comp.participantsCount + 1
              : (comp.participantsCount > 0 ? comp.participantsCount - 1 : 0);

          return comp.copyWith(participantsCount: newCount);
        }
        return comp;
      }).toList();

      _safeEmit(SearchCompetitionSuccess(updatedList));
    }
  }

  /// Prevents `StateError` if an async task completes after the Cubit has been closed.
  void _safeEmit(SearchCompetitionState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  /// Formats raw exception objects into user-friendly strings.
  String _formatErrorMessage(dynamic error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message.isEmpty ? 'An unexpected error occurred.' : message;
  }
}