abstract class CreateTeamState {}


class CreateTeamInitial 
extends CreateTeamState {}



class CreateTeamLoading 
extends CreateTeamState {}


class CreateTeamSuccess 
extends CreateTeamState {}


class CreateTeamError 
extends CreateTeamState {


final String message;


CreateTeamError(
this.message
);

}