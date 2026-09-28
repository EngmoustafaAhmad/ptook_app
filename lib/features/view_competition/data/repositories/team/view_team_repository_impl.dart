import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import 'package:ptook/features/view_competition/data/datasources/team/i_view_team_reamote_data_source.dart';
import 'package:ptook/features/view_competition/domain/repositories/team/i_view_team_repository.dart';

class ViewTeamRepositoryImpl implements IViewTeamRepository {
  final IViewTeamReamoteDataSource remoteDataSource;

  ViewTeamRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<void>> joinTeamCompetition(String competitionId) {
    return _guard(() => remoteDataSource.joinTeamCompetition(competitionId));
  }

  @override
  Future<Result<void>> leaveTeamCompetition(String competitionId) {
    return _guard(() => remoteDataSource.leaveTeamCompetition(competitionId));
  }

  @override
  Future<Result<void>> joinTeam({
    required String competitionId,
    required String teamId,
    String? joinCode,
  }) {
    return _guard(
      () => remoteDataSource.joinTeam(
        competitionId: competitionId,
        teamId: teamId,
        joinCode: joinCode,
      ),
    );
  }

  @override
  Future<Result<void>> leaveTeam({
    required String competitionId,
    required String teamId,
  }) {
    return _guard(
      () => remoteDataSource.leaveTeam(
        competitionId: competitionId,
        teamId: teamId,
      ),
    );
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

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      final data = await action();
      return Success(data);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }
}