import 'package:ptook/features/shared/data/models/competition_model.dart';

abstract class ICreateCompetitionRemoteDataSource {
  Future<void> createCompetition(CompetitionModel competition);
}