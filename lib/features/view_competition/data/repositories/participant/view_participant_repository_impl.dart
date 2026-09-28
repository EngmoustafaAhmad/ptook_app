import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/view_competition/data/datasources/participant/i_view_participant_remote_data_source.dart';
import 'package:ptook/features/view_competition/domain/repositories/participant/i_view_participant_repository.dart';

class ViewParticipantRepositoryImpl implements IViewParticipantRepository {
  final IViewParticipantRemoteDataSource remoteDataSource;

  ViewParticipantRepositoryImpl(this.remoteDataSource);



  @override
  Future<Result<void>> joinIndividualCompetition(String competitionId) {
    return _guard(() => remoteDataSource.joinIndividualCompetition(competitionId));
  }

  @override
  Future<Result<void>> leaveIndividualCompetition(String competitionId) {
    return _guard(() => remoteDataSource.leaveIndividualCompetition(competitionId));
  }




  @override
  Stream<List<ParticipantEntity>> streamParticipants(String competitionId) {
    return remoteDataSource
        .streamParticipants(competitionId)
        .map((models) => models.map((e) => e as ParticipantEntity).toList());
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

    @override
  Future<Result<List<ParticipantEntity>>> getParticipants(
    String competitionId,
  ) {
    return _guard(() => remoteDataSource.getParticipants(competitionId));
  }

}