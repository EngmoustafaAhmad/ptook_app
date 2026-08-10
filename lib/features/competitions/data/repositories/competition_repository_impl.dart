import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/data/datasources/competition_remote_data_source.dart';
import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/competition_repository.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

class CompetitionRepositoryImpl implements CompetitionRepository, ICompetitionRepository {
  final ICompetitionRemoteDataSource remoteDataSource;

  CompetitionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CompetitionEntity>>> getCompetitions() async {
    try {
      final competitions = await remoteDataSource.getCompetitions();
      return Right(competitions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetitionEntity>>> getPublicCompetitions() async {
    try {
      final competitions = await remoteDataSource.getPublicCompetitions();
      return Right(competitions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompetitionEntity>> getCompetitionById(
    String competitionId,
  ) async {
    try {
      final competition = await remoteDataSource.getCompetitionById(competitionId);
      return Right(competition);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetitionEntity>>> searchPublicCompetitions(
    String keyword,
  ) async {
    try {
      final competitions = await remoteDataSource.searchPublicCompetitions(keyword);
      return Right(competitions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompetitionEntity?>> getCompetitionByCode(
    String code,
  ) async {
    try {
      final competition = await remoteDataSource.getCompetitionByCode(code);
      return Right(competition);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinCompetition(String competitionId) async {
    try {
      await remoteDataSource.joinCompetition(competitionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveCompetition(String competitionId) async {
    try {
      await remoteDataSource.leaveCompetition(competitionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createCompetition(
    CompetitionEntity competition,
  ) async {
    try {
      final model = CompetitionModel.fromEntity(competition);
      await remoteDataSource.createCompetition(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCompetition(
    CompetitionEntity competition,
  ) async {
    try {
      final model = CompetitionModel.fromEntity(competition);
      await remoteDataSource.updateCompetition(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCompetition(
    String competitionId,
  ) async {
    try {
      await remoteDataSource.deleteCompetition(competitionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ===========================================================================
  // REALTIME STREAMS
  // ===========================================================================

  @override
  Stream<CompetitionEntity> streamCompetition(String competitionId) {
    return remoteDataSource.streamCompetition(competitionId);
  }

  @override
  Stream<List<ParticipantEntity>> streamParticipants(String competitionId) {
    return remoteDataSource.streamParticipants(competitionId);
  }
}