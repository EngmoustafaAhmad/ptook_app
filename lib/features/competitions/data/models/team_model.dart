import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
   TeamModel({
    required super.id,
    required super.name,
    required super.competitionId,
    required super.ownerId,
    required super.joinCode,
    required super.members,
    required super.membersCount,
    required super.maxMembers,
    required super.createdAt,
  });

  // 🎯 التحويل من JSON / Firestore Document
  factory TeamModel.fromJson(Map<String, dynamic> json, String docId) {
    return TeamModel(
      id: docId,
      name: json['name'] ?? '',
      competitionId: json['competitionId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      joinCode: json['joinCode'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      membersCount: json['membersCount'] ?? 0,
      maxMembers: json['maxMembers'] ?? 5,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // 🎯 التحويل إلى Map لإرساله لـ Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'competitionId': competitionId,
      'ownerId': ownerId,
      'joinCode': joinCode,
      'members': members,
      'membersCount': membersCount,
      'maxMembers': maxMembers,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // 🎯 تحويل الـ Entity القادمة من الـ Repository إلى Model
  factory TeamModel.fromEntity(TeamEntity entity) {
    return TeamModel(
      id: entity.id,
      name: entity.name,
      competitionId: entity.competitionId,
      ownerId: entity.ownerId,
      joinCode: entity.joinCode,
      members: entity.members,
      membersCount: entity.membersCount,
      maxMembers: entity.maxMembers,
      createdAt: entity.createdAt,
    );
  }
}