import 'package:ptook/features/shared/data/models/competition_model.dart';

abstract class IViewCompetitionRemoteDataSource {
  Future<List<CompetitionModel>> getCompetitions();

  Future<List<CompetitionModel>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<CompetitionModel> getCompetitionDetails({
    required String competitionId,
    required String userId,
  });

  // Favorites Actions
  Future<void> toggleFavorite({
    required String userId,
    required String competitionId,
    required bool isFavorite,
  });

  Future<bool> isFavorite({
    required String userId,
    required String competitionId,
  });

  Future<List<String>> getFavoriteCompetitionIds(String userId);

  Future<List<CompetitionModel>> getFavoriteCompetitions({
    String? userId,
    int limit = 10,
    String? lastCompetitionId,
  });

  // Real-time Streams
  Stream<CompetitionModel> streamCompetition({
    required String competitionId,
    required String userId,
  });

  Stream<List<String>> streamFavoriteCompetitionIds(String userId);
}