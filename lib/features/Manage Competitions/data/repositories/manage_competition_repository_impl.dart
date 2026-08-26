import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/shared/data/models/team_model.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../../shared/domain/entities/competition_entity.dart';
import '../../../shared/domain/entities/participant_entity.dart';
import '../../../shared/domain/entities/team_entity.dart';
import '../../domain/repositories/i_manage_competition_repository.dart';
import '../datasources/i_manage_competition_remote_data_source.dart';

class ManageCompetitionRepositoryImpl implements IManageCompetitionRepository {
  final IManageCompetitionRemoteDataSource remoteDataSource;

  ManageCompetitionRepositoryImpl(this.remoteDataSource);

  // ===========================================================================
  // ORGANIZER DASHBOARD FETCHING
  // ===========================================================================

  @override
  Future<Result<List<CompetitionEntity>>> getCreatedCompetitions({
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
      return Success(models);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // ===========================================================================
  // COMPETITION ADMINISTRATION
  // ===========================================================================

  @override
  Future<Result<void>> createCompetition(
    CompetitionEntity competition,
  ) async {
    try {
      final model = CompetitionModel.fromEntity(competition);
      await remoteDataSource.createCompetition(model);
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> updateCompetition(
    CompetitionEntity competition,
  ) async {
    try {
      final model = CompetitionModel.fromEntity(competition);
      await remoteDataSource.updateCompetition(model);
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteCompetition(String competitionId) async {
    try {
      await remoteDataSource.deleteCompetition(competitionId);
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> finishCompetition(String competitionId) async {
    try {
      await remoteDataSource.finishCompetition(competitionId);
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // ===========================================================================
  // PARTICIPANT MANAGEMENT
  // ===========================================================================

  @override
  Future<Result<void>> updateParticipantPoints({
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
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> removeParticipant({
    required String competitionId,
    required String participantId,
  }) async {
    try {
      await remoteDataSource.removeParticipant(
        competitionId: competitionId,
        participantId: participantId,
      );
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // ===========================================================================
  // TEAM ADMINISTRATION
  // ===========================================================================

  @override
  Future<Result<void>> createTeam(TeamEntity team) async {
    try {
      final model = TeamModel.fromEntity(team);
      await remoteDataSource.createTeam(model);
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteTeam({
    required String competitionId,
    required String teamId,
  }) async {
    try {
      await remoteDataSource.deleteTeam(
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
  Future<Result<void>> removeMember({
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
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> updateMemberPoints({
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
      return const Success(null);
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
        .map((models) => List<ParticipantEntity>.from(models));
  }

  @override
  Stream<List<TeamEntity>> streamTeams(String competitionId) {
    return remoteDataSource
        .streamTeams(competitionId)
        .map((models) => List<TeamEntity>.from(models));
  }
}