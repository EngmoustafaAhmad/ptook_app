import 'package:ptook/features/activity/domain/entities/activity_entity.dart';
import 'package:ptook/features/activity/domain/repositories/i_activity_repository.dart';

class StreamUserActivitiesUseCase {
  final IActivityRepository repository;

  StreamUserActivitiesUseCase(this.repository);

  Stream<List<ActivityEntity>> call(String userId) {
    return repository.streamUserActivities(userId);
  }
}