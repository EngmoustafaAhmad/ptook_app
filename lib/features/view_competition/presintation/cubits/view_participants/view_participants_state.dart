import 'package:flutter/foundation.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
// Ensure your ParticipantEntity import is present here:
// import 'package:your_app/features/competitions/domain/entities/participant_entity.dart';

@immutable
abstract class ViewParticipantsState {
  const ViewParticipantsState();
}

class ViewParticipantsInitial extends ViewParticipantsState {}

class ViewParticipantsLoading extends ViewParticipantsState {}

class ViewParticipantsActionLoading extends ViewParticipantsState {}

class ViewParticipantsLoaded extends ViewParticipantsState {
  final List<ParticipantEntity> participants;

  const ViewParticipantsLoaded(this.participants);
}

class ViewParticipantsError extends ViewParticipantsState {
  final String message;

  const ViewParticipantsError(this.message);
}

class JoinCompetitionSuccess extends ViewParticipantsState {
  final String message;

  const JoinCompetitionSuccess(this.message);
}

class LeaveCompetitionSuccess extends ViewParticipantsState {
  final String message;

  const LeaveCompetitionSuccess(this.message);
}