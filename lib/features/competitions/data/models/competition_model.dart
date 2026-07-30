import '../../domain/entities/competition_entity.dart';

class CompetitionModel extends CompetitionEntity {

  CompetitionModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.totalPoints,
    required super.endDate,
    required super.maxParticipants,
    required super.isPublic,
    required super.ownerId,
  });


  factory CompetitionModel.fromJson(
      Map<String, dynamic> json
  ) {

    return CompetitionModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      totalPoints: json['totalPoints'],
      endDate: json['endDate'],
      maxParticipants: json['maxParticipants'],
      isPublic: json['isPublic'],
      ownerId: json['ownerId'],
    );
  }


  Map<String, dynamic> toJson(){

    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'totalPoints': totalPoints,
      'endDate': endDate,
      'maxParticipants': maxParticipants,
      'isPublic': isPublic,
      'ownerId': ownerId,
    };

  }
}