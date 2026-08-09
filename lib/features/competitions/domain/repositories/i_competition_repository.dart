import '../entities/competition_entity.dart';

abstract class ICompetitionRepository {
  /// Creates a new competition
  Future<void> createCompetition(
    CompetitionEntity competition,
  );

  /// Searches public competitions by keyword
  Future<List<CompetitionEntity>> searchPublicCompetitions(
    String keyword,
  );

  /// Fetches all public competitions
  Future<List<CompetitionEntity>> getPublicCompetitions();

  /// Finds a competition by its invite code
  Future<CompetitionEntity?> getCompetitionByCode(
    String code,
  );
}