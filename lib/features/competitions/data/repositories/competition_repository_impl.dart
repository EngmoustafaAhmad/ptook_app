// lib/features/competitions/data/repositories/competition_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:ptook/features/competitions/data/datasources/competition_remote_data_source.dart';
import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class CompetitionRepositoryImpl implements ICompetitionRepository {
  final ICompetitionRemoteDataSource remoteDataSource;

  CompetitionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, Unit>> createCompetition(CompetitionEntity entity) async {
    try {
      final model = CompetitionModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        type: entity.type,
        totalPoints: entity.totalPoints,
        endDate: entity.endDate,
        maxParticipants: entity.maxParticipants,
        isPublic: entity.isPublic,
        creatorId: entity.creatorId,
      );
      await remoteDataSource.createCompetition(model);
      return const Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }
}