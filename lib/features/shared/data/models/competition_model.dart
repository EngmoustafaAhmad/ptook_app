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
    super.ownerName,
    super.ownerAvatarUrl,
    required super.inviteCode,
    super.joinCode,
    required super.category,
    required super.searchKeywords,
    required super.maxTeams,
    required super.maxTeamMembers,
    required super.participantsCount,
    required super.createdAt,
    required super.status,
    super.imageUrl,
    super.linkUrl,
    required super.winnerId,
    required super.participantIds,
    super.teamIds,
    super.isFavorite,
    super.participants,
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
      ownerName: entity.ownerName,
      ownerAvatarUrl: entity.ownerAvatarUrl,
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
      linkUrl: entity.linkUrl,
      winnerId: entity.winnerId,
      participantIds: entity.participantIds,
      teamIds: entity.teamIds,
      isFavorite: entity.isFavorite,
      participants: entity.participants,
      basePoints: entity.basePoints,
      penaltyPoints: entity.penaltyPoints,
      leaderboardVisibility: entity.leaderboardVisibility,
      rankChangeAlerts: entity.rankChangeAlerts,
      milestoneAlerts: entity.milestoneAlerts,
      multipliers: entity.multipliers,
    );
  }

  /// Deserializes Firestore JSON Map into Data Model
  factory CompetitionModel.fromJson(
    Map<String, dynamic> json, {
    String? id,
    bool isFavorite = false,
  }) {
    return CompetitionModel(
      id: id ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'individual',
      totalPoints: json['totalPoints'] ?? 0,
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      maxParticipants: json['maxParticipants'],
      isPublic: json['isPublic'] ?? true,
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'],
      ownerAvatarUrl: json['ownerAvatarUrl'],
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
      linkUrl: json['linkUrl'],
      winnerId: json['winnerId'],
      participantIds: Set<String>.from(json['participantIds'] ?? []),
      teamIds: Set<String>.from(json['teamIds'] ?? []),
      // Checks json['isFavorite'] first; falls back to explicit parameter passed from database queries
      isFavorite: json['isFavorite'] ?? isFavorite,
      participants: json['participants'],
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
      'ownerName': ownerName,
      'ownerAvatarUrl': ownerAvatarUrl,
      'inviteCode': inviteCode,
      'joinCode': joinCode,
      'category': category,
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
      'linkUrl': linkUrl,
      'winnerId': winnerId,
      'participantIds': participantIds.toList(),
      'teamIds': teamIds.toList(),
      'isFavorite': isFavorite,
      'participants': participants,
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
      ownerName: ownerName,
      ownerAvatarUrl: ownerAvatarUrl,
      category: category,
      status: status,
      type: type,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
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
      teamIds: teamIds,
      createdAt: createdAt,
      winnerId: winnerId,
      searchKeywords: searchKeywords,
      participantIds: participantIds,
      isFavorite: isFavorite,
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

    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }
}
