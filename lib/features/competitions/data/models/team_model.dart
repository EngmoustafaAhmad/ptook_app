import '../../domain/entities/team_entity.dart';


class TeamModel extends TeamEntity {


TeamModel({

required super.id,

required super.name,

required super.competitionId,

required super.ownerId,

required super.joinCode,

required super.members,

required super.createdAt,

});




factory TeamModel.fromJson(
Map<String,dynamic> json
){

return TeamModel(

id: json['id'],

name: json['name'],

competitionId:
json['competitionId'],

ownerId:
json['ownerId'],

joinCode:
json['joinCode'],

members:
List<String>.from(
json['members'] ?? []
),


createdAt:
DateTime.parse(
json['createdAt']
),


);


}





Map<String,dynamic> toJson(){


return {


'id':id,

'name':name,

'competitionId':
competitionId,

'ownerId':
ownerId,

'joinCode':
joinCode,

'members':
members,

'createdAt':
createdAt.toIso8601String(),


};
}
}