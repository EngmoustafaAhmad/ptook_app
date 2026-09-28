import 'package:ptook/features/activity/data/models/activity_model.dart';

abstract class IActivityRemoteDataSource {
  Stream<List<ActivityModel>> streamUserActivities(String userId);
  Future<void> logActivity(ActivityModel model);
}