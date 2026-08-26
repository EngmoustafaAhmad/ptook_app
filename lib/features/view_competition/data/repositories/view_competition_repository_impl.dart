import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../../shared/domain/entities/competition_entity.dart';
import '../../../shared/domain/entities/participant_entity.dart';
import '../../../shared/domain/entities/team_entity.dart';
import '../../domain/repositories/i_view_competition_repository.dart';
import '../datasources/i_view_competition_remote_data_source.dart';

class ViewCompetitionRepositoryImpl implements IViewCompetitionRepository {
  final IViewCompetitionRemoteDataSource remoteDataSource;

  ViewCompetitionRepositoryImpl(this.remoteDataSource, );

  // ===========================================================================
  // DISCOVERY & FETCHING
  // ===========================================================================

  @override
  Future<Result<List<CompetitionEntity>>> getCompetitions() async {
    try {
      final models = await remoteDataSource.getCompetitions();
      return Success(models);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<CompetitionEntity>>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    try {
      final models = await remoteDataSource.getPublicCompetitions(
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
      return Success(models);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<CompetitionEntity>>> searchPublicCompetitions({
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
      return Success(models);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<CompetitionEntity>>> getJoinedCompetitions({
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
      return Success(models);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<CompetitionEntity>> getCompetitionById(
    String competitionId,
  ) async {
    try {
      final model = await remoteDataSource.getCompetitionById(competitionId);
      return Success(model);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<CompetitionEntity?>> getCompetitionByCode(
    String code,
  ) async {
    try {
      final model = await remoteDataSource.getCompetitionByCode(code);
      return Success(model);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<CompetitionEntity>> getCompetitionDetails(
    String competitionId,
  ) async {
    try {
      final model =
          await remoteDataSource.getCompetitionDetails(competitionId);
      return Success(model);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // ===========================================================================
  // PARTICIPANT ACTIONS
  // ===========================================================================

  @override
  Future<Result<void>> joinCompetition(String competitionId) async {
    try {
      await remoteDataSource.joinCompetition(competitionId);
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> leaveCompetition(String competitionId) async {
    try {
      await remoteDataSource.leaveCompetition(competitionId);
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // ===========================================================================
  // TEAM INTERACTION ACTIONS
  // ===========================================================================

  @override
  Future<Result<TeamEntity>> createTeam({
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
      return Success(teamModel);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> joinTeam({
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
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> leaveTeam({
    required String competitionId,
    required String teamId,
  }) async {
    try {
      await remoteDataSource.leaveTeam(
        competitionId: competitionId,
        teamId: teamId,
      );
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> switchTeam({
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
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }
  @override
  Future<Result<List<ParticipantEntity>>> getParticipants(
    String competitionId,
  ) async {
    try {
      final models = await remoteDataSource.getParticipants(competitionId);
      return Success(models);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
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
    return remoteDataSource
        .streamParticipants(competitionId)
        .map((models) => models.map((e) => e as ParticipantEntity).toList());
  }

  @override
  Stream<List<TeamEntity>> streamTeams(String competitionId) {
    return remoteDataSource.streamTeams(competitionId);
  }


}