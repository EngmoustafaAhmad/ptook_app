import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/features/participants/data/models/participant_model.dart';
import '../../domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    required super.competitionId,
    required super.ownerId,
    super.joinCode,
    super.isPrivate = false,
    super.points = 0,
    super.members = const [],
    super.membersCount = 0,
    super.maxMembers = 5,
    required super.createdAt,
  });

  /// 🎯 Convert Firestore Document / JSON to TeamModel
  factory TeamModel.fromJson(Map<String, dynamic> json, String docId) {
    return TeamModel(
      id: docId,
      name: json['name'] ?? '',
      competitionId: json['competitionId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      joinCode: json['joinCode'] as String?,
      isPrivate: json['isPrivate'] ?? false,
      points: json['points'] ?? 0,
      members: json['members'] != null
          ? (json['members'] as List<dynamic>)
              .map((item) => ParticipantModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
      membersCount: json['membersCount'] ?? 0,
      maxMembers: json['maxMembers'] ?? 5,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// 🎯 Convert TeamModel to Map for Firestore persistence
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'competitionId': competitionId,
      'ownerId': ownerId,
      'joinCode': joinCode,
      'isPrivate': isPrivate,
      'points': points,
      'members': members
          .map((member) => ParticipantModel.fromEntity(member).toJson())
          .toList(),
      'membersCount': membersCount,
      'maxMembers': maxMembers,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 🎯 Convert domain TeamEntity to Data Model
  factory TeamModel.fromEntity(TeamEntity entity) {
    return TeamModel(
      id: entity.id,
      name: entity.name,
      competitionId: entity.competitionId,
      ownerId: entity.ownerId,
      joinCode: entity.joinCode,
      isPrivate: entity.isPrivate,
      points: entity.points,
      members: entity.members,
      membersCount: entity.membersCount,
      maxMembers: entity.maxMembers,
      createdAt: entity.createdAt,
    );
  }
}