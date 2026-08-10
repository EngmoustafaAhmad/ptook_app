import 'package:equatable/equatable.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

abstract class CompetitionHomeState extends Equatable {
  const CompetitionHomeState();

  @override
  List<Object?> get props => [];
}

class CompetitionHomeInitial extends CompetitionHomeState {}

class CompetitionHomeLoading extends CompetitionHomeState {}

class CompetitionHomeLoaded extends CompetitionHomeState {
  final CompetitionEntity competition;
  final List<ParticipantEntity> participants;

  const CompetitionHomeLoaded({
    required this.competition,
    required this.participants,
  });

  @override
  List<Object?> get props => [competition, participants];
}

class CompetitionHomeError extends CompetitionHomeState {
  final String message;

  const CompetitionHomeError(this.message);

  @override
  List<Object?> get props => [message];
}