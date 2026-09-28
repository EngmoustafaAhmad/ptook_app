import 'package:ptook/core/errors/failures.dart'; // Adjust path based on your failure class
import 'package:ptook/features/activity/domain/entities/activity_entity.dart';

abstract class IActivityRepository {
  Stream<List<ActivityEntity>> streamUserActivities(String userId);
  Future<void> logActivity(ActivityEntity activity);
}