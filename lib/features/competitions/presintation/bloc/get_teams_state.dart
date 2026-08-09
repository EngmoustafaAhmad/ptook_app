part of 'get_teams_cubit.dart';




abstract class GetTeamsState {}





class GetTeamsInitial 
    extends GetTeamsState {}





class GetTeamsLoading 
    extends GetTeamsState {}





class GetTeamsSuccess 
    extends GetTeamsState {



  final List<TeamEntity> teams;



  GetTeamsSuccess(
    this.teams,
  );



}







class GetTeamsError 
    extends GetTeamsState {



  final String message;



  GetTeamsError(
    this.message,
  );



}