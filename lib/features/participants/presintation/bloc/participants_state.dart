import 'package:equatable/equatable.dart';
import '../../domain/entities/participant_entity.dart';

abstract class ParticipantState extends Equatable {
  const ParticipantState();

  @override
  List<Object?> get props => [];
}

class ParticipantInitial extends ParticipantState {}

/// General loading state (e.g. initial leaderboard load)
class ParticipantLoading extends ParticipantState {}

/// Button/Action-specific loading state (e.g. tapping Join/Leave)
class ParticipantActionLoading extends ParticipantState {}

/// Loaded state with sorted participants
class ParticipantLoaded extends ParticipantState {
  final List<ParticipantEntity> participants;

  const ParticipantLoaded({required this.participants});

  @override
  List<Object?> get props => [participants];
}

class JoinCompetitionSuccess extends ParticipantState {
  final String message;

  const JoinCompetitionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class LeaveCompetitionSuccess extends ParticipantState {
  final String message;

  const LeaveCompetitionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ParticipantFailure extends ParticipantState {
  final String errorMessage;

  const ParticipantFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}



class ParticipantError extends ParticipantState {
  final String message;

  const ParticipantError(this.message);

  @override
  List<Object?> get props => [message];
}