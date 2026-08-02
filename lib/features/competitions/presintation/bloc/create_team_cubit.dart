import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/presintation/bloc/create_team_state.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/team_entity.dart';
import '../../domain/usecases/create_team_usecase.dart';




class CreateTeamCubit 
extends Cubit<CreateTeamState>{



final CreateTeamUseCase createTeamUseCase;

final FirebaseAuth auth;



CreateTeamCubit({

required this.createTeamUseCase,

required this.auth,

}) : super(CreateTeamInitial());




Future<void> createTeam({

required String competitionId,

required String name,


}) async {



emit(
CreateTeamLoading()
);




try {



final user =
auth.currentUser;



if(user == null){


emit(

CreateTeamError(
"User not logged in"
)

);


return;

}




final team = TeamEntity(



id:
const Uuid().v4(),



name:
name,



competitionId:
competitionId,



ownerId:
user.uid,



joinCode:
const Uuid()
.v4()
.substring(0,6)
.toUpperCase(),



members:[

user.uid

],



createdAt:
DateTime.now(),



);





await createTeamUseCase(
team
);




emit(
CreateTeamSuccess()
);





}catch(e){



emit(

CreateTeamError(
e.toString()
)

);


}



}




}