import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/activity/domain/entities/activity_entity.dart';
import 'package:ptook/features/activity/domain/usecases/stream_user_activities_usecase.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final StreamUserActivitiesUseCase _streamUserActivitiesUseCase;
  StreamSubscription? _activitySubscription;

  ActivityCubit({
    required StreamUserActivitiesUseCase streamUserActivitiesUseCase,
  })  : _streamUserActivitiesUseCase = streamUserActivitiesUseCase,
        super(const ActivityInitial());

  void fetchUserActivities(String userId) {
    emit(const ActivityLoading());
    _activitySubscription?.cancel();

    _activitySubscription = _streamUserActivitiesUseCase(userId).listen(
      (activities) {
        if (!isClosed) {
          emit(ActivityLoaded(activities: activities));
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(ActivityError("Failed to load activity log: $error"));
        }
      },
    );
  }

  void filterActivities(ActivityType? type) {
    if (state is ActivityLoaded) {
      final currentState = state as ActivityLoaded;
      emit(ActivityLoaded(
        activities: currentState.activities,
        filterType: type,
      ));
    }
  }

  @override
  Future<void> close() {
    _activitySubscription?.cancel();
    return super.close();
  }
}