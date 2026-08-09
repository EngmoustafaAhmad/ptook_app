part of 'get_competitions_cubit.dart';

abstract class GetCompetitionsState {
  const GetCompetitionsState();
}

class GetCompetitionsInitial extends GetCompetitionsState {
  const GetCompetitionsInitial();
}

class GetCompetitionsLoading extends GetCompetitionsState {
  const GetCompetitionsLoading();
}

class GetCompetitionsSuccess extends GetCompetitionsState {
  final List<CompetitionEntity> competitions;

  const GetCompetitionsSuccess(this.competitions);
}

class GetCompetitionsError extends GetCompetitionsState {
  final String message;

  const GetCompetitionsError(this.message);
}