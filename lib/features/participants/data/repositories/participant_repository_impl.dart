import '../../domain/entities/participant_entity.dart';
import '../../domain/repositories/i_participant_repository.dart';
import '../datasources/participant_remote_data_source.dart';

class ParticipantRepositoryImpl implements IParticipantRepository {
  final IParticipantRemoteDataSource remoteDataSource;

  ParticipantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> joinCompetition({
    required String competitionId,
    required String userId,
    String role = 'member',
    String? teamId,
  }) async {
    return await remoteDataSource.joinCompetition(
      competitionId: competitionId,
      userId: userId,
      role: role,
      teamId: teamId,
    );
  }

  @override
  Future<void> leaveCompetition({
    required String competitionId,
    required String userId,
  }) async {
    return await remoteDataSource.leaveCompetition(
      competitionId: competitionId,
      userId: userId,
    );
  }

  @override
  Future<List<ParticipantEntity>> getCompetitionParticipants(
    String competitionId,
  ) async {
    // ParticipantModel extends ParticipantEntity, so models double as entities cleanly
    return await remoteDataSource.getCompetitionParticipants(competitionId);
  }

  @override
  Future<void> updatePoints({
    required String competitionId,
    required String userId,
    required int points,
  }) async {
    return await remoteDataSource.updatePoints(
      competitionId: competitionId,
      userId: userId,
      points: points,
    );
  }

  @override
  Future<void> assignPodiumStars({
    required String competitionId,
    required String userId,
    required int rank,
  }) async {
    return await remoteDataSource.assignPodiumStars(
      competitionId: competitionId,
      userId: userId,
      rank: rank,
    );
  }
}