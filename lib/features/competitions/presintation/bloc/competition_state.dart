import 'package:equatable/equatable.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';

abstract class CompetitionState extends Equatable {
  const CompetitionState();

  @override
  List<Object?> get props => [];
}

class CompetitionInitial extends CompetitionState {}

class CompetitionLoading extends CompetitionState {}

class CompetitionsLoaded extends CompetitionState {
  final List<CompetitionEntity> competitions;

  const CompetitionsLoaded(this.competitions);

  @override
  List<Object?> get props => [competitions];
}

class CompetitionDetailsLoaded extends CompetitionState {
  final CompetitionEntity competition;

  const CompetitionDetailsLoaded(this.competition);

  @override
  List<Object?> get props => [competition];
}

class CompetitionActionSuccess extends CompetitionState {
  final String message;

  const CompetitionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CompetitionError extends CompetitionState {
  final String message;

  const CompetitionError(this.message);

  @override
  List<Object?> get props => [message];
}