import '../../domain/entities/competition_entity.dart';

class CompetitionModel extends CompetitionEntity {


  CompetitionModel({

    required super.id,

    required super.name,

    required super.description,

    required super.type,

    required super.totalPoints,

    required super.startDate,

    required super.endDate,

    required super.maxParticipants,

    required super.isPublic,

    required super.ownerId,

    required super.inviteCode,

    required super.category,

    required super.searchKeywords,

    required super.maxTeams,

    required super.membersPerTeam,

    required super.participantsCount,

    required super.createdAt,

    required super.status,

    required super.imageUrl,

    required super.winnerId,

  });



  factory CompetitionModel.fromJson(
      Map<String, dynamic> json
      ) {

    return CompetitionModel(

      id: json['id'] ?? '',


      name: json['name'] ?? '',


      description:
      json['description'] ?? '',



      type:
      json['type'] ?? 'individual',



      totalPoints:
      json['totalPoints'] ?? 0,



      startDate:
      _parseDate(json['startDate']),



      endDate:
      _parseDate(json['endDate']),



      maxParticipants:
      json['maxParticipants'] ?? 0,



      isPublic:
      json['isPublic'] ?? true,



      ownerId:
      json['ownerId'] ?? '',



      inviteCode:
      json['inviteCode'],



      category:
      json['category'] ?? '',



      searchKeywords:
      List<String>.from(
        json['searchKeywords'] ?? [],
      ),



      maxTeams:
      json['maxTeams'],



      membersPerTeam:
      json['membersPerTeam'],



      participantsCount:
      json['participantsCount'] ?? 0,



      createdAt:
      _parseDate(json['createdAt']),



      status:
      json['status'] ?? 'upcoming',



      imageUrl:
      json['imageUrl'],



      winnerId:
      json['winnerId'],

    );

  }





  Map<String, dynamic> toJson(){


    return {

      'id': id,


      'name': name,


      'description': description,


      'type': type,


      'totalPoints': totalPoints,



      'startDate':
      startDate.toIso8601String(),



      'endDate':
      endDate.toIso8601String(),



      'maxParticipants':
      maxParticipants,



      'isPublic':
      isPublic,



      'ownerId':
      ownerId,



      'inviteCode':
      inviteCode,



      'category':
      category,



      'searchKeywords':
      searchKeywords,



      'maxTeams':
      maxTeams,



      'membersPerTeam':
      membersPerTeam,



      'participantsCount':
      participantsCount,



      'createdAt':
      createdAt.toIso8601String(),



      'status':
      status,



      'imageUrl':
      imageUrl,



      'winnerId':
      winnerId,

    };

  }





  static DateTime _parseDate(dynamic value){

    if(value == null){

      return DateTime.now();

    }


    if(value is String){

      return DateTime.parse(value);

    }


    // Firestore Timestamp
    return value.toDate();

  }

}