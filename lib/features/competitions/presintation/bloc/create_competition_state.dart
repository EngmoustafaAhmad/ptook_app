abstract class CreateCompetitionState {}


// Initial state
class CreateCompetitionInitial extends CreateCompetitionState {}


// While saving to Firestore
class CreateCompetitionLoading extends CreateCompetitionState {}


// Successfully created
class CreateCompetitionSuccess extends CreateCompetitionState {}


// Error state
class CreateCompetitionError extends CreateCompetitionState {

  final String message;
  CreateCompetitionError(this.message);
}