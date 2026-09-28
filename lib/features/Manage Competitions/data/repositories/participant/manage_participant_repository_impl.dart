import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/participants/i_manage_participant_remote_data_source.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/participant/i_manage_participant_repository.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';

class ManageParticipantRepositoryImpl implements IManageParticipantRepository {
  final IManageParticipantRemoteDataSource remoteDataSource;

  ManageParticipantRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<void>> updateCompetitionParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  }) async {
    try {
      await remoteDataSource.updateCompetitionParticipantPoints(
        competitionId: competitionId,
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
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<ParticipantEntity>> streamParticipants(String competitionId) {
    return remoteDataSource
        .streamParticipants(competitionId)
        .map((models) => models.map((model) => model as ParticipantEntity).toList())
        .handleError((error) {
      if (error is ServerException) {
        throw error;
      }
      throw ServerException(error.toString());
    });
  }
}