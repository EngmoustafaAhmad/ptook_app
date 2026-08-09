import 'package:equatable/equatable.dart';

abstract class JoinCompetitionState extends Equatable {
  const JoinCompetitionState();

  @override
  List<Object?> get props => [];
}

class JoinCompetitionInitial extends JoinCompetitionState {}

class JoinCompetitionLoading extends JoinCompetitionState {}

class JoinCompetitionSuccess extends JoinCompetitionState {
  final String message;

  const JoinCompetitionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class LeaveCompetitionSuccess extends JoinCompetitionState {
  final String message;

  const LeaveCompetitionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class JoinCompetitionFailure extends JoinCompetitionState {
  final String errorMessage;

  const JoinCompetitionFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}