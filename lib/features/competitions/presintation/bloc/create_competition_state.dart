// lib/features/competitions/presintation/cubit/create_competition_state.dart
abstract class CreateCompetitionState {}

class CreateCompetitionInitial extends CreateCompetitionState {}
class CreateCompetitionLoading extends CreateCompetitionState {}
class CreateCompetitionSuccess extends CreateCompetitionState {}
class CreateCompetitionError extends CreateCompetitionState {
  final String message;
  CreateCompetitionError(this.message);
}