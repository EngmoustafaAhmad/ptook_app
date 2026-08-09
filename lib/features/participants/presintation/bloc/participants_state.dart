

import 'package:equatable/equatable.dart';

abstract class ParticipantState extends Equatable {
  const ParticipantState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any join/leave action is triggered
class ParticipantInitial extends ParticipantState {}

/// Emitted while network requests (join/leave) are processing
class ParticipantLoading extends ParticipantState {}

/// Emitted when joining a competition completes successfully
class JoinCompetitionSuccess extends ParticipantState {}

/// Emitted when leaving a competition completes successfully
class LeaveCompetitionSuccess extends ParticipantState {}

/// Emitted when participant list is retrieved successfully
class ParticipantsLoaded extends ParticipantState {
  final List<dynamic> participants;

  const ParticipantsLoaded(this.participants);

  @override
  List<Object?> get props => [participants];
}

/// Emitted when an exception occurs during any participant action
class ParticipantError extends ParticipantState {
  final String errorMessage;

  const ParticipantError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}