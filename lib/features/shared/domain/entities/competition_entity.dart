import 'package:equatable/equatable.dart';

import 'participant_entity.dart';

class CompetitionEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String? ownerName;
  final String? ownerAvatarUrl;
  final String category;
  final String status;
  final String type; // 'team' or 'individual'
  final String? imageUrl;
  final String? linkUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPoints;
  final int? maxParticipants;
  final int participantsCount;
  final bool isPublic;
  final String? inviteCode;
  final String? joinCode;
  final int? maxTeams;
  final int? maxTeamMembers;
  final List<ParticipantEntity>? participants;
  final Set<String> teamIds;
  final DateTime createdAt;
  final String? winnerId;
  final List<String> searchKeywords;
  final Set<String> participantIds;
  final bool isFavorite;

  // Settings & Scoring Parameters
  final double basePoints;
  final double penaltyPoints;
  final bool leaderboardVisibility;
  final bool rankChangeAlerts;
  final bool milestoneAlerts;
  final List<String> multipliers;

  const CompetitionEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    this.ownerName,
    this.ownerAvatarUrl,
    required this.category,
    required this.status,
    required this.type,
    this.imageUrl,
    this.linkUrl,
    required this.startDate,
    required this.endDate,
    required this.totalPoints,
    this.maxParticipants,
    required this.participantsCount,
    required this.isPublic,
    this.inviteCode,
    this.joinCode,
    this.maxTeams,
    this.maxTeamMembers,
    this.participants,
    this.teamIds = const {},
    required this.createdAt,
    this.winnerId,
    required this.searchKeywords,
    required this.participantIds,
    this.isFavorite = false,
    this.basePoints = 100.0,
    this.penaltyPoints = -15.0,
    this.leaderboardVisibility = true,
    this.rankChangeAlerts = true,
    this.milestoneAlerts = true,
    this.multipliers = const ['Streak x1.5', 'Underdog x2.0'],
  });

  // ===========================================================================
  // 💡 DOMAIN CONVENIENCE GETTERS
  // ===========================================================================

  /// Finds and returns the owner's `ParticipantEntity` if loaded in `participants`.
  ParticipantEntity? get ownerParticipant {
    if (participants == null || participants!.isEmpty) return null;
    try {
      return participants!.firstWhere(
        (p) => p.userId == ownerId || p.id == ownerId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Resolves display name: Explicit field -> Participant Object -> Default fallback.
  String get displayOwnerName {
    if (ownerName != null && ownerName!.isNotEmpty) return ownerName!;
    return ownerParticipant?.name ?? 'Organizer';
  }

  /// Resolves display avatar: Explicit field -> Participant Object -> Null fallback.
  String? get displayOwnerAvatarUrl {
    if (ownerAvatarUrl != null && ownerAvatarUrl!.isNotEmpty) {
      return ownerAvatarUrl;
    }
    return ownerParticipant?.avatarUrl;
  }

  /// True if competition type is team-based.
  bool get isTeamBased => type.toLowerCase() == 'team';

  /// True if status indicates completion or current date is past end date.
  bool get isFinished =>
      status.toLowerCase() == 'finished' ||
      status.toLowerCase() == 'completed' ||
      DateTime.now().isAfter(endDate);

  /// Performs an O(1) direct lookup on `participantIds`, fallback checking nested arrays.
  bool isJoinedBy(String? userId) {
    if (userId == null || userId.isEmpty) return false;

    // 1. Fast path: Direct O(1) native Set lookup
    if (participantIds.contains(userId)) return true;

    // 2. Fallback: Check individual participants list
    if (participants != null && participants!.isNotEmpty) {
      final isParticipant =
          participants!.any((p) => p.id == userId || p.userId == userId);
      if (isParticipant) return true;
    }

    return false;
  }

  CompetitionEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? ownerName,
    String? ownerAvatarUrl,
    String? category,
    String? status,
    String? type,
    String? imageUrl,
    String? linkUrl,
    DateTime? startDate,
    DateTime? endDate,
    int? totalPoints,
    int? maxParticipants,
    int? participantsCount,
    bool? isPublic,
    String? inviteCode,
    String? joinCode,
    int? maxTeams,
    int? maxTeamMembers,
    List<ParticipantEntity>? participants,
    Set<String>? teamIds,
    DateTime? createdAt,
    String? winnerId,
    List<String>? searchKeywords,
    Set<String>? participantIds,
    bool? isFavorite,
    double? basePoints,
    double? penaltyPoints,
    bool? leaderboardVisibility,
    bool? rankChangeAlerts,
    bool? milestoneAlerts,
    List<String>? multipliers,
  }) {
    return CompetitionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPoints: totalPoints ?? this.totalPoints,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantsCount: participantsCount ?? this.participantsCount,
      isPublic: isPublic ?? this.isPublic,
      inviteCode: inviteCode ?? this.inviteCode,
      joinCode: joinCode ?? this.joinCode,
      maxTeams: maxTeams ?? this.maxTeams,
      maxTeamMembers: maxTeamMembers ?? this.maxTeamMembers,
      participants: participants ?? this.participants,
      teamIds: teamIds ?? this.teamIds,
      createdAt: createdAt ?? this.createdAt,
      winnerId: winnerId ?? this.winnerId,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      participantIds: participantIds ?? this.participantIds,
      isFavorite: isFavorite ?? this.isFavorite,
      basePoints: basePoints ?? this.basePoints,
      penaltyPoints: penaltyPoints ?? this.penaltyPoints,
      leaderboardVisibility:
          leaderboardVisibility ?? this.leaderboardVisibility,
      rankChangeAlerts: rankChangeAlerts ?? this.rankChangeAlerts,
      milestoneAlerts: milestoneAlerts ?? this.milestoneAlerts,
      multipliers: multipliers ?? this.multipliers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ownerId,
        ownerName,
        ownerAvatarUrl,
        category,
        status,
        type,
        imageUrl,
        linkUrl,
        startDate,
        endDate,
        totalPoints,
        maxParticipants,
        participantsCount,
        isPublic,
        inviteCode,
        joinCode,
        maxTeams,
        maxTeamMembers,
        participants,
        teamIds,
        createdAt,
        winnerId,
        searchKeywords,
        participantIds,
        isFavorite,
        basePoints,
        penaltyPoints,
        leaderboardVisibility,
        rankChangeAlerts,
        milestoneAlerts,
        multipliers,
      ];
}