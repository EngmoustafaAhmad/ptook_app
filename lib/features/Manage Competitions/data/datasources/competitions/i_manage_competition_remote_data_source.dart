import 'package:ptook/features/shared/data/models/competition_model.dart';

abstract class IManageCompetitionRemoteDataSource {
  // Competition Administration
  Future<void> updateCompetition(CompetitionModel competition);
  Future<void> deleteCompetition(String competitionId);
  Future<void> finishCompetition(String competitionId);

  Stream<CompetitionModel> streamCompetition(String competitionId);
}