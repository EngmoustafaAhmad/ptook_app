import 'package:ptook/features/activity/data/datasources/i_activity_remote_data_source.dart';
import 'package:ptook/features/activity/data/models/activity_model.dart';
import 'package:ptook/features/activity/domain/entities/activity_entity.dart';
import 'package:ptook/features/activity/domain/repositories/i_activity_repository.dart';

class ActivityRepositoryImpl implements IActivityRepository {
  final IActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ActivityEntity>> streamUserActivities(String userId) {
    return remoteDataSource.streamUserActivities(userId);
  }

  @override
  Future<void> logActivity(ActivityEntity activity) async {
    final model = ActivityModel(
      id: activity.id,
      userId: activity.userId,
      title: activity.title,
      description: activity.description,
      type: activity.type,
      timestamp: activity.timestamp,
      competitionId: activity.competitionId,
      powerAmount: activity.powerAmount,
    );
    await remoteDataSource.logActivity(model);
  }
}