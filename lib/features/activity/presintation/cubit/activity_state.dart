import 'package:equatable/equatable.dart';
import 'package:ptook/features/activity/domain/entities/activity_entity.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {
  const ActivityInitial();
}

class ActivityLoading extends ActivityState {
  const ActivityLoading();
}

class ActivityLoaded extends ActivityState {
  final List<ActivityEntity> activities;
  final ActivityType? filterType;

  const ActivityLoaded({
    required this.activities,
    this.filterType,
  });

  List<ActivityEntity> get filteredActivities {
    if (filterType == null) return activities;
    return activities.where((a) => a.type == filterType).toList();
  }

  @override
  List<Object?> get props => [activities, filterType];
}

class ActivityError extends ActivityState {
  final String message;

  const ActivityError(this.message);

  @override
  List<Object?> get props => [message];
}