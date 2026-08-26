import 'package:equatable/equatable.dart';

import 'participant_entity.dart';
import 'team_entity.dart';

class CompetitionEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String category;
  final String status;
  final String type; // 'team' or 'individual'
  final String? imageUrl;
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
  final List<TeamEntity>? teams;
  final DateTime createdAt;
  final String? winnerId;
  final List<String> searchKeywords;
  final Set<String> participantIds;

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
    required this.category,
    required this.status,
    required this.type,
    this.imageUrl,
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
    this.teams,
    required this.createdAt,
    this.winnerId,
    required this.searchKeywords,
    required this.participantIds,
    this.basePoints = 100.0,
    this.penaltyPoints = -15.0,
    this.leaderboardVisibility = true,
    this.rankChangeAlerts = true,
    this.milestoneAlerts = true,
    this.multipliers = const ['Streak x1.5', 'Underdog x2.0'],
  });

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
      final isParticipant = participants!.any((p) => p.id == userId || p.userId == userId);
      if (isParticipant) return true;
    }

    // 3. Fallback: Check team members list
    if (teams != null && teams!.isNotEmpty) {
      final isTeamMember = teams!.any((t) => t.members.any((m) => m.id == userId || m.userId == userId));
      if (isTeamMember) return true;
    }

    return false;
  }

  CompetitionEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? category,
    String? status,
    String? type,
    String? imageUrl,
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
    List<TeamEntity>? teams,
    DateTime? createdAt,
    String? winnerId,
    List<String>? searchKeywords,
    Set<String>? participantIds,
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
      category: category ?? this.category,
      status: status ?? this.status,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
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
      teams: teams ?? this.teams,
      createdAt: createdAt ?? this.createdAt,
      winnerId: winnerId ?? this.winnerId,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      participantIds: participantIds ?? this.participantIds,
      basePoints: basePoints ?? this.basePoints,
      penaltyPoints: penaltyPoints ?? this.penaltyPoints,
      leaderboardVisibility: leaderboardVisibility ?? this.leaderboardVisibility,
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
        category,
        status,
        type,
        imageUrl,
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
        teams,
        createdAt,
        winnerId,
        searchKeywords,
        participantIds,
        basePoints,
        penaltyPoints,
        leaderboardVisibility,
        rankChangeAlerts,
        milestoneAlerts,
        multipliers,
      ];
}