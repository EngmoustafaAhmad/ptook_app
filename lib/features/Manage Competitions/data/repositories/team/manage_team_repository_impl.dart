import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/teams/i_manage_team_remote_data_source.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/team/i_manage_team_repository.dart';
import 'package:ptook/features/shared/data/models/team_model.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

class ManageTeamRepositoryImpl implements IManageTeamRepository {
  final IManageTeamRemoteDataSource remoteDataSource;

  ManageTeamRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<void>> createTeam(TeamEntity team) async {
    try {
      final model = TeamModel.fromEntity(team);
      await remoteDataSource.createTeam(model);
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
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
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateTeamParticipantPoints({
    required String competitionId,
    required String teamId,
    required String participantId,
    required int addedPoints,
  }) async {
    try {
      await remoteDataSource.updateTeamParticipantPoints(
        competitionId: competitionId,
        teamId: teamId,
        participantId: participantId,
        addedPoints: addedPoints,
      );
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> removeTeamParticipant({
    required String competitionId,
    required String teamId,
    required String participantId,
  }) async {
    try {
      await remoteDataSource.removeTeamParticipant(
        competitionId: competitionId,
        teamId: teamId,
        participantId: participantId,
      );
      return const Success(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<TeamEntity>> streamTeams(String competitionId) {
    return remoteDataSource
        .streamTeams(competitionId)
        .map((models) => models.map((model) => model as TeamEntity).toList())
        .handleError((error) {
      if (error is ServerException) {
        throw error;
      }
      throw ServerException(error.toString());
    });
  }
} 