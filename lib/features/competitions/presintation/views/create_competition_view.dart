import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/context_extentions.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';

import 'package:ptook/features/auth/presintation/widgets/auth_text_field.dart';

import '../bloc/create_competition_cubit.dart';
import '../bloc/create_competition_state.dart';



class CreateCompetitionView extends StatefulWidget {


  final VoidCallback onSuccess;


  const CreateCompetitionView({

    super.key,

    required this.onSuccess,

  });



  @override
  State<CreateCompetitionView> createState() =>
      _CreateCompetitionViewState();

}







class _CreateCompetitionViewState
    extends State<CreateCompetitionView> {



final _formKey =
GlobalKey<FormState>();



final _nameController =
TextEditingController();


final _descController =
TextEditingController();


final _pointsController =
TextEditingController();


final _participantsController =
TextEditingController();


final _maxTeamsController =
TextEditingController();


final _membersController =
TextEditingController();





String _selectedType =
"individual";


bool _isPublic =
true;



String? _selectedCategory;



DateTime?
_startDate;


DateTime?
_endDate;





final List<String> categories = [

"Programming",

"Mobile Development",

"Web Development",

"Artificial Intelligence",

"Machine Learning",

"Cyber Security",

"Data Science",

"UI/UX Design",

"Algorithms",

"Other",

];







@override
void dispose(){


_nameController.dispose();

_descController.dispose();

_pointsController.dispose();

_participantsController.dispose();

_maxTeamsController.dispose();

_membersController.dispose();


super.dispose();


}








Future<void> pickDate(
bool start
) async {



final date =
await showDatePicker(

context: context,


firstDate:
DateTime.now(),


lastDate:
DateTime(2030),


initialDate:
DateTime.now(),

);



if(date != null){


setState(() {


if(start){

_startDate = date;

}else{

_endDate = date;

}


});


}


}









@override
Widget build(BuildContext context){


return Scaffold(


backgroundColor:
AppColors.background,



body: SafeArea(


child:

BlocConsumer<CreateCompetitionCubit,
CreateCompetitionState>(


listener:(context,state){


if(state is CreateCompetitionSuccess){

context.showSuccess(
"Competition Created 🚀"
);


widget.onSuccess();

}



if(state is CreateCompetitionError){

context.showError(
state.message
);

}


},





builder:(context,state){



return SingleChildScrollView(


padding:
const EdgeInsets.all(24),



child:Form(


key:_formKey,



child:Column(


crossAxisAlignment:
CrossAxisAlignment.start,


children:[




const Text(

"Create Competition",

style:TextStyle(

color:Colors.white,

fontSize:26,

fontWeight:
FontWeight.bold,

),

),



24.vs,






Row(

children:[


_typeButton(

"individual",

Icons.person,

"Individuals"

),


16.hs,


_typeButton(

"team",

Icons.groups,

"Teams"

),


],


),





24.vs,





AuthTextField(

label:"Competition Name",

hintText:"Flutter Championship",

prefixIcon:
Icons.emoji_events,


controller:
_nameController,


validator:(v)=>

v!.isEmpty
?
"Required"
:null,


),




16.vs,





AuthTextField(

label:"Description",

hintText:"Rules and details",

prefixIcon:
Icons.description,


controller:
_descController,


validator:(v)=>

v!.isEmpty
?
"Required"
:null,


),





16.vs,






DropdownButtonFormField<String>(


value:
_selectedCategory,



dropdownColor:
AppColors.surface,



decoration:
_inputDecoration(

"Category",

Icons.category,

),



items:

categories.map((e){

return DropdownMenuItem(

value:e,

child:Text(

e,

style:
const TextStyle(
color:Colors.white
),

),

);


}).toList(),




onChanged:(v){

setState(() {

_selectedCategory=v;

});

},



validator:(v)=>

v==null
?
"Select category"
:null,


),





16.vs,






AuthTextField(

label:"Total Points",

hintText:"1000",

prefixIcon:
Icons.star,


controller:
_pointsController,


keyboardType:
TextInputType.number,


validator:(v){

if(int.tryParse(v??"")==null){

return "Invalid number";

}

return null;

},


),





16.vs,







if(_selectedType=="individual")


AuthTextField(

label:"Max Participants",

hintText:"100",

prefixIcon:
Icons.people,


controller:
_participantsController,


keyboardType:
TextInputType.number,

validator:(v)=>

v!.isEmpty
?
"Required"
:null,


),





if(_selectedType=="team")...[


AuthTextField(

label:"Maximum Teams",

hintText:"20",

prefixIcon:
Icons.groups,


controller:
_maxTeamsController,


keyboardType:
TextInputType.number,


validator:(v)=>

v!.isEmpty
?
"Required"
:null,


),



16.vs,



AuthTextField(

label:"Members Per Team",

hintText:"5",

prefixIcon:
Icons.person_add,


controller:
_membersController,


keyboardType:
TextInputType.number,


validator:(v)=>

v!.isEmpty
?
"Required"
:null,


),


],







16.vs,






Row(

children:[


Expanded(

child:
_dateButton(

"Start Date",

_startDate,

(){

pickDate(true);

}

),

),


16.hs,


Expanded(

child:
_dateButton(

"End Date",

_endDate,

(){

pickDate(false);

}

),

),


],


),






16.vs,






Row(

mainAxisAlignment:
MainAxisAlignment.spaceBetween,


children:[


const Text(

"Public Competition",

style:
TextStyle(

color:Colors.white,

fontSize:16,

),

),




Switch(

value:_isPublic,


activeColor:
AppColors.primary,


onChanged:(v){

setState(() {

_isPublic=v;

});

},

)


],


),






24.vs,








SizedBox(

width:double.infinity,


height:55,


child:
ElevatedButton(


onPressed:
state is CreateCompetitionLoading
?
null
:
_submit,



style:
ElevatedButton.styleFrom(

backgroundColor:
AppColors.primary,


),



child:

state is CreateCompetitionLoading

?
const CircularProgressIndicator()

:

const Text(
"Launch Competition 🚀"
),


),

)





],


),


),


);



}


),



),



);



}








Widget _typeButton(
String type,
IconData icon,
String title
){


final selected =
_selectedType==type;



return Expanded(

child:
InkWell(

onTap:(){

setState(() {

_selectedType=type;

});

},


child:
Container(

padding:
const EdgeInsets.all(16),


decoration:
BoxDecoration(

color:selected
?
AppColors.primary
:
AppColors.surface,


borderRadius:
BorderRadius.circular(12),

),


child:Row(

mainAxisAlignment:
MainAxisAlignment.center,

children:[


Icon(

icon,

color:selected
?
Colors.black
:
Colors.white,

),


8.hs,


Text(

title,

style:
TextStyle(

color:selected
?
Colors.black
:
Colors.white,

),

)


],


),

),


),


);



}








Widget _dateButton(
String title,
DateTime? date,
VoidCallback onTap
){


return InkWell(

onTap:onTap,


child:Container(

padding:
const EdgeInsets.all(14),


decoration:
BoxDecoration(

color:
AppColors.surface,


borderRadius:
BorderRadius.circular(12),

),


child:Text(

date==null
?
title
:
"${date.day}/${date.month}/${date.year}",


style:
const TextStyle(

color:Colors.white,

),

),


),


);


}







InputDecoration _inputDecoration(
String label,
IconData icon
){

return InputDecoration(

labelText:label,


labelStyle:
const TextStyle(
color:Colors.white70
),


prefixIcon:
Icon(

icon,

color:
AppColors.primary,

),


filled:true,


fillColor:
AppColors.surface,


border:
OutlineInputBorder(

borderRadius:
BorderRadius.circular(12),


borderSide:
BorderSide.none,

),

);

}









void _submit(){



if(!_formKey.currentState!.validate())
return;



if(_startDate==null ||
_endDate==null){


context.showError(
"Select dates"
);


return;

}




int maxParticipants;



int? maxTeams;


int? membersPerTeam;




if(_selectedType=="individual"){


maxParticipants =
int.parse(
_participantsController.text
);



}else{


maxTeams =
int.parse(
_maxTeamsController.text
);



membersPerTeam =
int.parse(
_membersController.text
);



maxParticipants =
maxTeams *
membersPerTeam;


}

context
.read<CreateCompetitionCubit>()
.submitCompetition(

name:_nameController.text.trim(),
description:_descController.text.trim(),
type:_selectedType,



totalPoints:
int.parse(
_pointsController.text
),



startDate:
_startDate!,



endDate:
_endDate!,



maxParticipants:
maxParticipants,



isPublic:
_isPublic,



category:
_selectedCategory!,



maxTeams:
maxTeams,


membersPerTeam:
membersPerTeam,



);


}



}