import 'package:flutter/material.dart';

import '../../domain/entities/competition_entity.dart';

import 'manage_individual_competition_view.dart';
import 'manage_team_competition_view.dart';



class ManageCompetitionView extends StatelessWidget {


  final CompetitionEntity competition;



  const ManageCompetitionView({

    super.key,

    required this.competition,

  });





  @override
  Widget build(BuildContext context) {



    if(competition.type == "team"){


      return ManageTeamCompetitionView(

        competition: competition,

      );


    }



    return ManageIndividualCompetitionView(

      competition: competition,

    );


  }



}