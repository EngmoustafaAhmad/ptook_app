import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/features/search_competitions/domain/entity/competition_page.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';


abstract class ISearchCompetitionRemoteDataSource {
  // ===========================================================================
  // DISCOVERY & SEARCH (STREAM MODE VS SEARCH MODE)
  // ===========================================================================

  /// Real-time stream of active competitions (Stream Mode)
  ///
  /// Listens to real-time updates for active competitions matching the [filter].
  /// Supports snapshot cursor pagination via [startAfter].
  Stream<CompetitionPage<CompetitionModel>> streamActiveCompetitions({
    required CompetitionFilter filter,
    required String currentUserId,
    int limit = 10,
    DocumentSnapshot? startAfter,
  });

  /// One-time fetch for keyword search on active competitions (Search Mode)
  ///
  /// Fetches active competitions filtering by [query] and [filter].
  /// Supports snapshot cursor pagination via [startAfter].
  Future<CompetitionPage<CompetitionModel>> searchActiveCompetitions({
    required String query,
    required CompetitionFilter filter,
    required String currentUserId,
    int limit = 10,
    DocumentSnapshot? startAfter,
  });

}