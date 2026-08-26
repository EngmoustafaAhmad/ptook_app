part of 'search_competition_cubit.dart';

abstract class SearchCompetitionState {
  const SearchCompetitionState();
}

/// Initial state when the cubit is first instantiated
class SearchCompetitionInitial extends SearchCompetitionState {}

/// State emitted when fetching or switching stream feeds
class SearchCompetitionLoading extends SearchCompetitionState {}

/// State emitted when an error occurs while fetching or streaming data
class SearchCompetitionError extends SearchCompetitionState {
  final String message;

  const SearchCompetitionError(this.message);
}

/// State emitted when data is successfully loaded or updated via real-time streams
class SearchCompetitionSuccess extends SearchCompetitionState {
  final List<CompetitionEntity> competitions;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const SearchCompetitionSuccess({
    required this.competitions,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  /// Helper copyWith method to allow local updates (e.g., pagination, local updates)
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