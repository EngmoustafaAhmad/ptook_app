import 'package:equatable/equatable.dart';

abstract class CreateCompetitionState extends Equatable {
  const CreateCompetitionState();

  @override
  List<Object?> get props => [];
}

class CreateCompetitionInitial extends CreateCompetitionState {
  const CreateCompetitionInitial();
}

class CreateCompetitionLoading extends CreateCompetitionState {
  const CreateCompetitionLoading();
}

class CreateCompetitionSuccess extends CreateCompetitionState {
  const CreateCompetitionSuccess();
}

class CreateCompetitionError extends CreateCompetitionState {
  final String message;

  const CreateCompetitionError(this.message);

  @override
  List<Object?> get props => [message];
}