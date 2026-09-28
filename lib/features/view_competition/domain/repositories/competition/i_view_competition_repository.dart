import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

abstract class IViewCompetitionRepository {
  Future<Result<List<CompetitionEntity>>> getCompetitions();

  Future<Result<CompetitionEntity>> getCompetitionDetails({
    required String competitionId,
    required String userId,
  });

  // Favorites Actions
  Future<Result<void>> toggleFavorite({
    required String userId,
    required String competitionId,
    required bool isFavorite,
  });

  Future<Result<bool>> isFavorite({
    required String userId,
    required String competitionId,
  });

  Future<Result<List<String>>> getFavoriteCompetitionIds(String userId);

  Future<Result<List<CompetitionEntity>>> getFavoriteCompetitions({
    String? userId,
    int limit = 10,
    String? lastCompetitionId,
  });

  // Realtime Streams
  Stream<CompetitionEntity> streamCompetition({
    required String competitionId,
    required String userId,
  });

  Stream<List<String>> streamFavoriteCompetitionIds(String userId);
}