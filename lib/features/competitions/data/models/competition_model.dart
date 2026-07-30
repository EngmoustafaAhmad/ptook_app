// lib/features/competitions/data/models/competition_model.dart
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';

class CompetitionModel extends CompetitionEntity {
  const CompetitionModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.totalPoints,
    required super.endDate,
    required super.maxParticipants,
    required super.isPublic,
    required super.creatorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'totalPoints': totalPoints,
      'endDate': endDate,
      'maxParticipants': maxParticipants,
      'isPublic': isPublic,
      'creatorId': creatorId,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}