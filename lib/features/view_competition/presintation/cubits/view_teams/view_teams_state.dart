import 'package:flutter/foundation.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

@immutable
abstract class ViewTeamsState {
  const ViewTeamsState();
}

class ViewTeamsInitial extends ViewTeamsState {}

class ViewTeamsLoading extends ViewTeamsState {}

class ViewTeamsLoaded extends ViewTeamsState {
  final List<TeamEntity> teams;

  const ViewTeamsLoaded(this.teams);
}

class ViewTeamsError extends ViewTeamsState {
  final String message;

  const ViewTeamsError(this.message);
}