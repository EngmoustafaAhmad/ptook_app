part of 'search_competition_cubit.dart';


abstract class SearchCompetitionState {}



class SearchCompetitionInitial 
    extends SearchCompetitionState {}



class SearchCompetitionLoading 
    extends SearchCompetitionState {}



class SearchCompetitionSuccess 
    extends SearchCompetitionState {


  final List<CompetitionEntity> competitions;


  SearchCompetitionSuccess(
      this.competitions,
  );

}



class SearchCompetitionError 
    extends SearchCompetitionState {


  final String message;


  SearchCompetitionError(
      this.message,
  );

}