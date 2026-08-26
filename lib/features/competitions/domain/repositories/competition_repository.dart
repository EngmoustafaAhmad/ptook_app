

// abstract class CompetitionRepository  {

//   /// Fetches public competitions (paginated)
//   Future<Result<List<CompetitionEntity>>> getPublicCompetitions({
//     int limit = 10,
//     String? lastCompetitionId,
//   });

//   /// Searches public competitions by query string (paginated)
//   Future<Result<List<CompetitionEntity>>> searchPublicCompetitions({
//     required String query,
//     int limit = 10,
//     String? lastCompetitionId,
//   });

//   /// Fetches competitions joined by current user with optional query filter (paginated)
//   Future<Result<List<CompetitionEntity>>> getJoinedCompetitions({
//     String? query,
//     int limit = 10,
//     String? lastCompetitionId,
//   });

//   /// Fetches competitions created by current user with optional query filter (paginated)
//   Future<Result<List<CompetitionEntity>>> getCreatedCompetitions({
//     String? query,
//     int limit = 10,
//     String? lastCompetitionId,
//   });

// }
