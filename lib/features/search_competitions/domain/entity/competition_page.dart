import 'package:equatable/equatable.dart';

/// Clean Architecture abstraction for cursor-based paginated results.
class CompetitionPage<T> extends Equatable {
  final List<T> items;
  final Object? nextCursor; // Opaque token holding DocumentSnapshot
  final bool hasMore;

  const CompetitionPage({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, nextCursor, hasMore];
}
