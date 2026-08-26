import 'package:ptook/core/utils/search_keywords_generator.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

class CompetitionModel extends CompetitionEntity {
  const CompetitionModel({
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
    super.joinCode,
    required super.category,
    required super.searchKeywords,
    required super.maxTeams,
    required super.maxTeamMembers,
    required super.participantsCount,
    required super.createdAt,
    required super.status,
    required super.imageUrl,
    required super.winnerId,
    required super.participantIds,
    super.participants,
    super.teams,
    super.basePoints,
    super.penaltyPoints,
    super.leaderboardVisibility,
    super.rankChangeAlerts,
    super.milestoneAlerts,
    super.multipliers,
  });

  /// Converts Domain Entity to Data Model
  factory CompetitionModel.fromEntity(CompetitionEntity entity) {
    return CompetitionModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      type: entity.type,
      totalPoints: entity.totalPoints,
      startDate: entity.startDate,
      endDate: entity.endDate,
      maxParticipants: entity.maxParticipants,
      isPublic: entity.isPublic,
      ownerId: entity.ownerId,
      inviteCode: entity.inviteCode,
      joinCode: entity.joinCode,
      category: entity.category,
      searchKeywords: entity.searchKeywords,
      maxTeams: entity.maxTeams,
      maxTeamMembers: entity.maxTeamMembers,
      participantsCount: entity.participantsCount,
      createdAt: entity.createdAt,
      status: entity.status,
      imageUrl: entity.imageUrl,
      winnerId: entity.winnerId,
      participantIds: entity.participantIds,
      participants: entity.participants,
      teams: entity.teams,
      basePoints: entity.basePoints,
      penaltyPoints: entity.penaltyPoints,
      leaderboardVisibility: entity.leaderboardVisibility,
      rankChangeAlerts: entity.rankChangeAlerts,
      milestoneAlerts: entity.milestoneAlerts,
      multipliers: entity.multipliers,
    );
  }

  /// Deserializes Firestore JSON Map into Data Model
  factory CompetitionModel.fromJson(Map<String, dynamic> json, String id) {
    return CompetitionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'individual',
      totalPoints: json['totalPoints'] ?? 0,
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      maxParticipants: json['maxParticipants'],
      isPublic: json['isPublic'] ?? true,
      ownerId: json['ownerId'] ?? '',
      inviteCode: json['inviteCode'],
      joinCode: json['joinCode'],
      category: json['category'] ?? '',
      searchKeywords: List<String>.from(json['searchKeywords'] ?? []),
      maxTeams: json['maxTeams'],
      maxTeamMembers: json['maxTeamMembers'],
      participantsCount: json['participantsCount'] ?? 0,
      createdAt: _parseDate(json['createdAt']),
      status: json['status'] ?? 'upcoming',
      imageUrl: json['imageUrl'],
      winnerId: json['winnerId'],
      participantIds: Set<String>.from(json['participantIds'] ?? []),
      participants: json['participants'],
      teams: json['teams'],
      basePoints: (json['basePoints'] as num?)?.toDouble() ?? 100.0,
      penaltyPoints: (json['penaltyPoints'] as num?)?.toDouble() ?? -15.0,
      leaderboardVisibility: json['leaderboardVisibility'] ?? true,
      rankChangeAlerts: json['rankChangeAlerts'] ?? true,
      milestoneAlerts: json['milestoneAlerts'] ?? true,
      multipliers: json['multipliers'] != null
          ? List<String>.from(json['multipliers'])
          : const ['Streak x1.5', 'Underdog x2.0'],
    );
  }

  /// Serializes Data Model into Firestore Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'totalPoints': totalPoints,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'maxParticipants': maxParticipants,
      'isPublic': isPublic,
      'ownerId': ownerId,
      'inviteCode': inviteCode,
      'joinCode': joinCode,
      'category': category,

      // Auto-generate keywords if empty to prevent search misses in Firestore
      'searchKeywords': searchKeywords.isNotEmpty
          ? searchKeywords
          : SearchKeywordsGenerator.generate(
              name: name,
              category: category,
            ),

      'maxTeams': maxTeams,
      'maxTeamMembers': maxTeamMembers,
      'participantsCount': participantsCount,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'imageUrl': imageUrl,
      'winnerId': winnerId,
      'participantIds': participantIds,
      'participants': participants,
      'teams': teams,
      'basePoints': basePoints,
      'penaltyPoints': penaltyPoints,
      'leaderboardVisibility': leaderboardVisibility,
      'rankChangeAlerts': rankChangeAlerts,
      'milestoneAlerts': milestoneAlerts,
      'multipliers': multipliers,
    };
  }

  /// Converts Data Model back to pure Domain Entity
  CompetitionEntity toEntity() {
    return CompetitionEntity(
      id: id,
      name: name,
      description: description,
      ownerId: ownerId,
      category: category,
      status: status,
      type: type,
      imageUrl: imageUrl,
      startDate: startDate,
      endDate: endDate,
      totalPoints: totalPoints,
      maxParticipants: maxParticipants,
      participantsCount: participantsCount,
      isPublic: isPublic,
      inviteCode: inviteCode,
      joinCode: joinCode,
      maxTeams: maxTeams,
      maxTeamMembers: maxTeamMembers,
      participants: participants,
      teams: teams,
      createdAt: createdAt,
      winnerId: winnerId,
      searchKeywords: searchKeywords,
      participantIds: participantIds,
      basePoints: basePoints,
      penaltyPoints: penaltyPoints,
      leaderboardVisibility: leaderboardVisibility,
      rankChangeAlerts: rankChangeAlerts,
      milestoneAlerts: milestoneAlerts,
      multipliers: multipliers,
    );
  }

  /// Safely converts String, ISO8601, or Firestore Timestamp to DateTime
  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    // Handles Firestore Timestamp objects cleanly
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }
}