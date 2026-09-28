import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/search_competitions/domain/entity/competition_page.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';


abstract class ISearchCompetitionRepository {
  // ===========================================================================
  // DISCOVERY & SEARCH (STREAM MODE VS SEARCH MODE)
  // ===========================================================================

  /// STREAM MODE: Real-time stream of active competitions with cursor-based pagination.
  ///
  /// Supports [CompetitionFilter.all], [CompetitionFilter.joined], and [CompetitionFilter.myCreated].
  /// Requires empty search query.
  Stream<CompetitionPage<CompetitionEntity>> streamActiveCompetitions({
    required CompetitionFilter filter,
    required String currentUserId,
    int limit = 10,
    CompetitionCursor? startAfter,
  });

  /// SEARCH MODE: One-shot debounced search query for active competitions with cursor-based pagination.
  ///
  /// Supports [CompetitionFilter.all], [CompetitionFilter.joined], and [CompetitionFilter.myCreated].
  /// Cancels active stream when active.
  Future<Result<CompetitionPage<CompetitionEntity>>> searchActiveCompetitions({
    required String query,
    required CompetitionFilter filter,
    required String currentUserId,
    int limit = 10,
    CompetitionCursor? startAfter,
  });
}