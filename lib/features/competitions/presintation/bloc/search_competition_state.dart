part of 'search_competition_cubit.dart';

abstract class SearchCompetitionState {}

class SearchCompetitionInitial extends SearchCompetitionState {}

class SearchCompetitionLoading extends SearchCompetitionState {}

class SearchCompetitionError extends SearchCompetitionState {
  final String message;
  SearchCompetitionError(this.message);
}

class SearchCompetitionSuccess extends SearchCompetitionState {
  final List<CompetitionEntity> competitions;
  final bool hasReachedMax;
  final bool isLoadingMore;

  SearchCompetitionSuccess({
    required this.competitions,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  SearchCompetitionSuccess copyWith({
    List<CompetitionEntity>? competitions,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return SearchCompetitionSuccess(
      competitions: competitions ?? this.competitions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}