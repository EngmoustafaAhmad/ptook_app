import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/competition_entity.dart';
import '../../domain/usecases/create_competition_usecase.dart';
import 'create_competition_state.dart';



class CreateCompetitionCubit 
    extends Cubit<CreateCompetitionState> {


  final CreateCompetitionUseCase createCompetitionUseCase;

  final FirebaseAuth auth;


  CreateCompetitionCubit({

    required this.createCompetitionUseCase,

    required this.auth,

  }) : super(CreateCompetitionInitial());





Future<void> submitCompetition({

  required String name,

  required String description,

  required String type,

  required int totalPoints,

  required DateTime startDate,

  required DateTime endDate,

  required int maxParticipants,

  required bool isPublic,

  required String category,


  // Team settings

  int? maxTeams,

  int? membersPerTeam,


}) async {



  emit(
    CreateCompetitionLoading(),
  );



  try {



    final user = auth.currentUser;



    if(user == null){

      emit(
        CreateCompetitionError(
          "User not logged in",
        ),
      );

      return;

    }





    // ============================
    // Validation
    // ============================


    if(type == "team"){


      if(maxTeams == null || membersPerTeam == null){

        emit(
          CreateCompetitionError(
            "Team settings are required",
          ),
        );

        return;

      }


    }else{


      if(maxParticipants <= 0){

        emit(
          CreateCompetitionError(
            "Maximum participants required",
          ),
        );

        return;

      }


    }







    // ============================
    // Private competition code
    // ============================


    String? inviteCode;


    if(!isPublic){

      inviteCode =
          const Uuid()
              .v4()
              .substring(0,8);

    }







    final competitionId =
        const Uuid().v4();





    final competition = CompetitionEntity(


      id:
      competitionId,



      name:
      name,



      description:
      description,



      type:
      type,



      totalPoints:
      totalPoints,



      startDate:
      startDate,



      endDate:
      endDate,



      maxParticipants:

      type == "individual"

          ? maxParticipants

          : (maxTeams! * membersPerTeam!),





      isPublic:
      isPublic,



      ownerId:
      user.uid,



      inviteCode:
      inviteCode,



      category:
      category,



      searchKeywords:
      [],




      // TEAM ONLY

      maxTeams:

      type == "team"

          ? maxTeams

          : null,



      membersPerTeam:

      type == "team"

          ? membersPerTeam

          : null,






      participantsCount:
      0,



      createdAt:
      DateTime.now(),



      status:
      "upcoming",



      imageUrl:
      null,



      winnerId:
      null,



    );







    await createCompetitionUseCase(
      competition,
    );





    emit(
      CreateCompetitionSuccess(),
    );





  }catch(e){



    emit(
      CreateCompetitionError(
        e.toString(),
      ),
    );


  }


}



}