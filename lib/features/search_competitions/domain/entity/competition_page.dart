import 'package:equatable/equatable.dart';

/// Enum representing discovery filter options.
enum CompetitionFilter {
  all,
  joined,
  myCreated,
}

/// Mode selector determined by search query state.
enum CompetitionLoadMode {
  stream,
  search,
}

/// Framework-agnostic cursor wrapper that encapsulates underlying 
/// database pagination tokens (e.g., Firestore DocumentSnapshot) 
/// without leaking infrastructure details to the Domain layer.
class CompetitionCursor extends Equatable {
  final Object? rawCursor;

  const CompetitionCursor(this.rawCursor);

  @override
  List<Object?> get props => [rawCursor];
}

/// Clean Architecture abstraction for cursor-based paginated results.
class CompetitionPage<T> extends Equatable {
  final List<T> items;
  final CompetitionCursor? nextCursor;
  final bool hasMore;

  const CompetitionPage({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, nextCursor, hasMore];
}