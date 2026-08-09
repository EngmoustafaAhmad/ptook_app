import 'package:flutter_bloc/flutter_bloc.dart';


import '../../domain/entities/team_entity.dart';

import '../../domain/repositories/i_team_repository.dart';



part 'get_teams_state.dart';



class GetTeamsCubit

extends Cubit<GetTeamsState>{



final ITeamRepository repository;



GetTeamsCubit({

required this.repository

})
:super(GetTeamsInitial());






Future<void> loadTeams(

String competitionId

) async {



emit(
GetTeamsLoading()
);




try{


final teams =
await repository.getTeams(
competitionId
);



emit(

GetTeamsSuccess(
teams
)

);



}

catch(e){


emit(

GetTeamsError(
e.toString()
)

);


}



}




}