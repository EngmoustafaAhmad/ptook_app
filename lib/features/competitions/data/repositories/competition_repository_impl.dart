import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/data/datasources/i_competition_remote_data_source.dart';
import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/entities/team_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'package:ptook/features/participants/data/models/participant_model.dart';

class CompetitionRepositoryImpl implements ICompetitionRepository {
  final ICompetitionRemoteDataSource remoteDataSource;

  CompetitionRepositoryImpl(this.remoteDataSource);

  // ===========================================================================
  // COMPETITION ACTIONS
  // ===========================================================================

  @override
  Future<Either<Failure, List<CompetitionEntity>>> getCompetitions() async {
    try {
      final models = await remoteDataSource.getCompetitions();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompetitionEntity>> getCompetitionById(
      String competitionId) async {
    try {
      final model = await remoteDataSource.getCompetitionById(competitionId);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompetitionEntity>> getCompetitionDetails(
      String competitionId) async {
    try {
      final model =
          await remoteDataSource.getCompetitionDetails(competitionId);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompetitionEntity?>> getCompetitionByCode(
      String code) async {
    try {
      final model = await remoteDataSource.getCompetitionByCode(code);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createCompetition(
      CompetitionEntity competition) async {
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
      CompetitionEntity competition) async {
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
  Future<Either<Failure, void>> deleteCompetition(String competitionId) async {
    try {
      await remoteDataSource.deleteCompetition(competitionId);
      return const Right(null);
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

  // ===========================================================================
  // MANAGEMENT ACTIONS
  // ===========================================================================

  @override
  Future<Either<Failure, void>> finishCompetition(String competitionId) async {
    try {
      await remoteDataSource.finishCompetition(competitionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  }) async {
    try {
      await remoteDataSource.updateParticipantPoints(
        competitionId: competitionId,
        participantId: participantId,
        addedPoints: addedPoints,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeParticipant({
    required String competitionId,
    required String participantId,
  }) async {
    try {
      await remoteDataSource.removeParticipant(
        competitionId: competitionId,
        participantId: participantId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ===========================================================================
  // TEAM MANAGEMENT ACTIONS
  // ===========================================================================

  @override
  Future<Either<Failure, TeamEntity>> createTeam({
    required String competitionId,
    required String name,
    bool isPrivate = false,
    String? joinCode,
  }) async {
    try {
      final teamModel = await remoteDataSource.createTeam(
        competitionId: competitionId,
        name: name,
        isPrivate: isPrivate,
        joinCode: joinCode,
      );
      return Right(teamModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTeam({
    required String competitionId,
    required String teamId,
  }) async {
    try {
      await remoteDataSource.deleteTeam(
        competitionId: competitionId,
        teamId: teamId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinTeam({
    required String competitionId,
    required String teamId,
    String? joinCode,
  }) async {
    try {
      await remoteDataSource.joinTeam(
        competitionId: competitionId,
        teamId: teamId,
        joinCode: joinCode,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveTeam({
    required String competitionId,
    required String teamId,
  }) async {
    try {
      await remoteDataSource.leaveTeam(
        competitionId: competitionId,
        teamId: teamId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> switchTeam({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  }) async {
    try {
      await remoteDataSource.switchTeam(
        competitionId: competitionId,
        fromTeamId: fromTeamId,
        toTeamId: toTeamId,
        joinCode: joinCode,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember({
    required String competitionId,
    required String teamId,
    required String memberId,
  }) async {
    try {
      await remoteDataSource.removeMember(
        competitionId: competitionId,
        teamId: teamId,
        memberId: memberId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMemberPoints({
    required String competitionId,
    required String teamId,
    required String memberId,
    required int points,
  }) async {
    try {
      await remoteDataSource.updateMemberPoints(
        competitionId: competitionId,
        teamId: teamId,
        memberId: memberId,
        points: points,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ===========================================================================
  // PAGINATED FETCHING & SEARCH
  // ===========================================================================

  @override
  Future<Either<Failure, List<CompetitionEntity>>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    try {
      final models = await remoteDataSource.getPublicCompetitions(
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetitionEntity>>> searchPublicCompetitions({
    String query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    try {
      final models = await remoteDataSource.searchPublicCompetitions(
        query: query,
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetitionEntity>>> getJoinedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    try {
      final models = await remoteDataSource.getJoinedCompetitions(
        query: query,
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetitionEntity>>> getCreatedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    try {
      final models = await remoteDataSource.getCreatedCompetitions(
        query: query,
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
      return Right(models);
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
  Stream<List<ParticipantModel>> streamParticipants(String competitionId) {
    return remoteDataSource.streamParticipants(competitionId);
  }

  @override
  Stream<List<TeamEntity>> streamTeams(String competitionId) {
    return remoteDataSource.streamTeams(competitionId);
  }
}