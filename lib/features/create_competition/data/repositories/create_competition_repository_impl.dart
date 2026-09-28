import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import '../../domain/repositories/i_create_competition_repository.dart';
import '../datasources/i_create_competition_remote_datasource.dart';

class CreateCompetitionRepositoryImpl implements ICreateCompetitionRepository {
  final ICreateCompetitionRemoteDataSource _remoteDataSource;

  CreateCompetitionRepositoryImpl({
    required ICreateCompetitionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<void>> createCompetition(CompetitionEntity competition) async {
    try {
      final model = CompetitionModel.fromEntity(competition);
      await _remoteDataSource.createCompetition(model);
      return const Success(null);
    } catch (e) {
      return Err(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}