import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/view_competition/data/datasources/competition/i_view_competition_remote_data_source.dart';
import 'package:ptook/features/view_competition/domain/repositories/competition/i_view_competition_repository.dart';

class ViewCompetitionRepositoryImpl implements IViewCompetitionRepository {
  final IViewCompetitionRemoteDataSource remoteDataSource;

  ViewCompetitionRepositoryImpl(this.remoteDataSource);

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      final data = await action();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CompetitionEntity>>> getCompetitions() {
    return _guard(() => remoteDataSource.getCompetitions());
  }

  @override
  Future<Result<CompetitionEntity>> getCompetitionDetails({
    required String competitionId,
    required String userId,
  }) {
    return _guard(
      () => remoteDataSource.getCompetitionDetails(
        competitionId: competitionId,
        userId: userId,
      ),
    );
  }

  @override
  Future<Result<void>> toggleFavorite({
    required String userId,
    required String competitionId,
    required bool isFavorite,
  }) {
    return _guard(
      () => remoteDataSource.toggleFavorite(
        userId: userId,
        competitionId: competitionId,
        isFavorite: isFavorite,
      ),
    );
  }

  @override
  Future<Result<bool>> isFavorite({
    required String userId,
    required String competitionId,
  }) {
    return _guard(
      () => remoteDataSource.isFavorite(
        userId: userId,
        competitionId: competitionId,
      ),
    );
  }

  @override
  Future<Result<List<String>>> getFavoriteCompetitionIds(String userId) {
    return _guard(() => remoteDataSource.getFavoriteCompetitionIds(userId));
  }

  @override
  Future<Result<List<CompetitionEntity>>> getFavoriteCompetitions({
    String? userId,
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _guard(
      () => remoteDataSource.getFavoriteCompetitions(
        userId: userId,
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      ),
    );
  }

  @override
  Stream<CompetitionEntity> streamCompetition({
    required String competitionId,
    required String userId,
  }) {
    return remoteDataSource.streamCompetition(
      competitionId: competitionId,
      userId: userId,
    );
  }

  @override
  Stream<List<String>> streamFavoriteCompetitionIds(String userId) {
    return remoteDataSource.streamFavoriteCompetitionIds(userId);
  }
}