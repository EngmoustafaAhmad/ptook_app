import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../../shared/domain/entities/competition_entity.dart';
import '../../../shared/domain/entities/participant_entity.dart';
import '../../../shared/domain/entities/team_entity.dart';
import '../../domain/repositories/i_view_competition_repository.dart';
import '../datasources/i_view_competition_remote_data_source.dart';

class ViewCompetitionRepositoryImpl implements IViewCompetitionRepository {
  final IViewCompetitionRemoteDataSource remoteDataSource;

  ViewCompetitionRepositoryImpl(this.remoteDataSource);

  // ===========================================================================
  // DISCOVERY & FETCHING
  // ===========================================================================

  @override
  Future<Result<List<CompetitionEntity>>> getCompetitions() {
    return _guard(() => remoteDataSource.getCompetitions());
  }

  @override
  Future<Result<List<CompetitionEntity>>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _guard(
      () => remoteDataSource.getPublicCompetitions(
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      ),
    );
  }

  @override
  Future<Result<List<CompetitionEntity>>> searchPublicCompetitions({
    String query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _guard(
      () => remoteDataSource.searchPublicCompetitions(
        query: query,
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      ),
    );
  }

  @override
  Future<Result<List<CompetitionEntity>>> getJoinedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _guard(
      () => remoteDataSource.getJoinedCompetitions(
        query: query,
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      ),
    );
  }

  @override
  Future<Result<CompetitionEntity>> getCompetitionById(
    String competitionId,
  ) {
    return _guard(() => remoteDataSource.getCompetitionById(competitionId));
  }

  @override
  Future<Result<CompetitionEntity?>> getCompetitionByCode(
    String code,
  ) {
    return _guard(() => remoteDataSource.getCompetitionByCode(code));
  }

  @override
  Future<Result<CompetitionEntity>> getCompetitionDetails({
    required String competitionId,
    required String userId,
  }) {
    return _guard(
      () => remoteDataSource.getCompetitionDetails(
        competitionId: competitionId,
        userId: userId,
      ),
    );
  }

  // ===========================================================================
  // FAVORITES ACTIONS
  // ===========================================================================

  @override
  Future<Result<void>> toggleFavorite({
    required String userId,
    required String competitionId,
    required bool isFavorite,
  }) {
    return _guard(
      () => remoteDataSource.toggleFavorite(
        userId: userId,
        competitionId: competitionId,
        isFavorite: isFavorite,
      ),
    );
  }

  @override
  Future<Result<bool>> isFavorite({
    required String userId,
    required String competitionId,
  }) {
    return _guard(
      () => remoteDataSource.isFavorite(
        userId: userId,
        competitionId: competitionId,
      ),
    );
  }

  @override
  Future<Result<List<String>>> getFavoriteCompetitionIds(String userId) {
    return _guard(() => remoteDataSource.getFavoriteCompetitionIds(userId));
  }

  @override
  Future<Result<List<CompetitionEntity>>> getFavoriteCompetitions({
    required String userId,
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _guard(
      () => remoteDataSource.getFavoriteCompetitions(
        userId: userId,
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      ),
    );
  }

  // ===========================================================================
  // PARTICIPANT ACTIONS
  // ===========================================================================

  @override
  Future<Result<void>> joinIndividualCompetition(String competitionId) {
    return _guard(() => remoteDataSource.joinIndividualCompetition(competitionId));
  }

  @override
  Future<Result<void>> leaveIndividualCompetition(String competitionId) {
    return _guard(() => remoteDataSource.leaveIndividualCompetition(competitionId));
  }

  @override
  Future<Result<void>> joinTeamCompetition(String competitionId) {
    return _guard(() => remoteDataSource.joinTeamCompetition(competitionId));
  }

  @override
  Future<Result<void>> leaveTeamCompetition(String competitionId) {
    return _guard(() => remoteDataSource.leaveTeamCompetition(competitionId));
  }

  @override
  Future<Result<List<ParticipantEntity>>> getParticipants(
    String competitionId,
  ) {
    return _guard(() => remoteDataSource.getParticipants(competitionId));
  }

  // ===========================================================================
  // TEAM INTERACTION ACTIONS
  // ===========================================================================

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
  Future<Result<void>> switchTeam({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  }) {
    return _guard(
      () => remoteDataSource.switchTeam(
        competitionId: competitionId,
        fromTeamId: fromTeamId,
        toTeamId: toTeamId,
        joinCode: joinCode,
      ),
    );
  }

  // ===========================================================================
  // REAL-TIME STREAMS
  // ===========================================================================

  @override
  Stream<CompetitionEntity> streamCompetition({
    required String competitionId,
    required String userId,
  }) {
    return remoteDataSource.streamCompetition(
      competitionId: competitionId,
      userId: userId,
    );
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

  @override
  Stream<List<String>> streamFavoriteCompetitionIds(String userId) {
    return remoteDataSource.streamFavoriteCompetitionIds(userId);
  }

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      final data = await action();
      return Success(data);
    } on ServerException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}