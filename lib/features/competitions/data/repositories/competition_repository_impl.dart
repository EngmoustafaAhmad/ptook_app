import 'package:ptook/features/competitions/data/datasources/competition_remote_data_source.dart';
import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class CompetitionRepositoryImpl implements ICompetitionRepository {
  final ICompetitionRemoteDataSource remoteDataSource;

  CompetitionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<void> createCompetition(
    CompetitionEntity competition,
  ) async {
    final model = CompetitionModel.fromEntity(competition);
    await remoteDataSource.createCompetition(model);
  }

  @override
  Future<List<CompetitionEntity>> searchPublicCompetitions(
    String keyword,
  ) async {
    final models = await remoteDataSource.searchPublicCompetitions(keyword);
    return models;
  }

  @override
  Future<List<CompetitionEntity>> getPublicCompetitions() async {
    final models = await remoteDataSource.getPublicCompetitions();
    return models;
  }

  @override
  Future<CompetitionEntity?> getCompetitionByCode(
    String code,
  ) async {
    final model = await remoteDataSource.getCompetitionByCode(code);
    return model;
  }
}