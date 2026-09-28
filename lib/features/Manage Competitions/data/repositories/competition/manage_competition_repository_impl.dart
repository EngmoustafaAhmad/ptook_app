import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/competitions/i_manage_competition_remote_data_source.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/competition/i_manage_competition_repository.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

class ManageCompetitionRepositoryImpl implements IManageCompetitionRepository {
  final IManageCompetitionRemoteDataSource remoteDataSource;

  ManageCompetitionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<void>> updateCompetition(
    CompetitionEntity competition,
  ) async {
    try {
      final model = CompetitionModel.fromEntity(competition);
      await remoteDataSource.updateCompetition(model);
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCompetition(String competitionId) async {
    try {
      await remoteDataSource.deleteCompetition(competitionId);
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> finishCompetition(String competitionId) async {
    try {
      await remoteDataSource.finishCompetition(competitionId);
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<CompetitionEntity> streamCompetition(String competitionId) {
    return remoteDataSource
        .streamCompetition(competitionId)
        .map((model) => model as CompetitionEntity);
  }
}