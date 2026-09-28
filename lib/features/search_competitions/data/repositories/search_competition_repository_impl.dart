import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/search_competitions/data/datasources/i_search_competition_remote_data_source.dart';
import 'package:ptook/features/search_competitions/domain/entity/competition_page.dart';
import 'package:ptook/features/search_competitions/domain/repositories/i_search_competition_repository.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

class SearchCompetitionRepositoryImpl implements ISearchCompetitionRepository {
  final ISearchCompetitionRemoteDataSource _remoteDataSource;

  SearchCompetitionRepositoryImpl(this._remoteDataSource);

  // ===========================================================================
  // DISCOVERY & SEARCH (STREAM MODE VS SEARCH MODE)
  // ===========================================================================

  @override
  Stream<CompetitionPage<CompetitionEntity>> streamActiveCompetitions({
    required CompetitionFilter filter,
    required String currentUserId,
    int limit = 10,
    CompetitionCursor? startAfter,
  }) {
    final rawCursor = startAfter?.rawCursor as DocumentSnapshot?;

    return _remoteDataSource
        .streamActiveCompetitions(
          filter: filter,
          currentUserId: currentUserId,
          limit: limit,
          startAfter: rawCursor,
        )
        .map(
          (page) => CompetitionPage<CompetitionEntity>(
            items: page.items.map((model) => model.toEntity()).toList(),
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
          ),
        );
  }

  @override
  Future<Result<CompetitionPage<CompetitionEntity>>> searchActiveCompetitions({
    required String query,
    required CompetitionFilter filter,
    required String currentUserId,
    int limit = 10,
    CompetitionCursor? startAfter,
  }) async {
    try {
      final rawCursor = startAfter?.rawCursor as DocumentSnapshot?;

      final page = await _remoteDataSource.searchActiveCompetitions(
        query: query,
        filter: filter,
        currentUserId: currentUserId,
        limit: limit,
        startAfter: rawCursor,
      );

      final domainPage = CompetitionPage<CompetitionEntity>(
        items: page.items.map((model) => model.toEntity()).toList(),
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );

      return Success(domainPage);
    } on FirebaseException catch (e) {
      return Err(ServerFailure(e.message ?? 'A database error occurred.'));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }
}