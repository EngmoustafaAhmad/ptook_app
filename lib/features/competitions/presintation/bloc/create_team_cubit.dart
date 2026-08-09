import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/presintation/bloc/get_teams_cubit.dart';

import '../../domain/entities/team_entity.dart';
import '../../domain/usecases/get_teams_usecase.dart';





class GetTeamsCubit 
    extends Cubit<GetTeamsState> {



  final GetTeamsUseCase getTeamsUseCase;




  GetTeamsCubit({

    required this.getTeamsUseCase, required Object auth,

  }) 
  : super(
      GetTeamsInitial()
    );








  Future<void> loadTeams(

      String competitionId

      ) async {



    emit(
      GetTeamsLoading()
    );




    try {



      final List<TeamEntity> teams =

      await getTeamsUseCase(

        competitionId,

      );





      emit(

        GetTeamsSuccess(

          teams,

        ),

      );





    } catch(e) {



      emit(

        GetTeamsError(

          e.toString(),

        ),

      );



    }



  }



}