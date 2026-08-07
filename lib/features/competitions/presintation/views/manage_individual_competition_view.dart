import 'package:flutter/material.dart';

import '../../domain/entities/competition_entity.dart';


class ManageIndividualCompetitionView 
extends StatelessWidget {


final CompetitionEntity competition;


const ManageIndividualCompetitionView({

super.key,

required this.competition,

});




@override
Widget build(BuildContext context){


return Scaffold(

appBar: AppBar(

title: const Text(
"Manage Competition"
),

),



body: Column(

children: [


Text(
competition.name,
),



const Text(
"Individual Competition"
),



],

),


);


}


}