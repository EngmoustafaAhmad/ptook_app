import 'package:flutter/material.dart';

import '../../domain/entities/competition_entity.dart';



class ManageTeamCompetitionView 
extends StatelessWidget {


final CompetitionEntity competition;



const ManageTeamCompetitionView({

super.key,

required this.competition,

});




@override
Widget build(BuildContext context){


return Scaffold(


appBar: AppBar(

title:
const Text(
"Manage Teams"
),

),




body: Column(

children: [



Text(

competition.name,

),



Text(

"Max Teams: ${competition.maxTeams}",

),



ElevatedButton(

onPressed: (){

// Create Team

},


child:
const Text(
"Create Team"
),

),


],

),


);


}


}