import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/data/datasources/competition_remote_data_source.dart';
import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

class CompetitionRepositoryImpl implements ICompetitionRepository {
  final ICompetitionRemoteDataSource remoteDataSource;

CompetitionRepositoryImpl(this.remoteDataSource);
  @override
  Future<Either<Failure, List<CompetitionEntity>>> getCompetitions() async {
    try {
      final result = await remoteDataSource.getCompetitions();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CompetitionEntity>>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    try {
      final result = await remoteDataSource.getPublicCompetitions(
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CompetitionEntity>>> searchPublicCompetitions({
    String query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    try {
      final result = await remoteDataSource.searchPublicCompetitions(
        query: query,
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CompetitionEntity>>> getJoinedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    try {
      final result = await remoteDataSource.getJoinedCompetitions(
        query: query,
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CompetitionEntity>>> getCreatedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    try {
      final result = await remoteDataSource.getCreatedCompetitions(
        query: query,
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CompetitionEntity>> getCompetitionById(
      String competitionId) async {
    try {
      final result = await remoteDataSource.getCompetitionById(competitionId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CompetitionEntity?>> getCompetitionByCode(
      String code) async {
    try {
      final result = await remoteDataSource.getCompetitionByCode(code);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CompetitionEntity>> getCompetitionDetails(
      String competitionId) async {
    try {
      final result =
          await remoteDataSource.getCompetitionDetails(competitionId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> createCompetition(
      CompetitionEntity competition) async {
    try {
      final model = competition is CompetitionModel
          ? competition
          : CompetitionModel.fromEntity(competition);
      await remoteDataSource.createCompetition(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateCompetition(
      CompetitionEntity competition) async {
    try {
      final model = competition is CompetitionModel
          ? competition
          : CompetitionModel.fromEntity(competition);
      await remoteDataSource.updateCompetition(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCompetition(String competitionId) async {
    try {
      await remoteDataSource.deleteCompetition(competitionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> joinCompetition(String competitionId) async {
    try {
      await remoteDataSource.joinCompetition(competitionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> leaveCompetition(String competitionId) async {
    try {
      await remoteDataSource.leaveCompetition(competitionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<CompetitionEntity> streamCompetition(String competitionId) {
    return remoteDataSource.streamCompetition(competitionId);
  }

  @override
  Stream<List<ParticipantEntity>> streamParticipants(String competitionId) {
    return remoteDataSource.streamParticipants(competitionId);
  }
}