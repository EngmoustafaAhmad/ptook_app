import 'package:equatable/equatable.dart';

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
  final int? maxTeams;
  final int? membersPerTeam;
  final List<dynamic>? participants;
  final List<dynamic>? teams;
  final DateTime createdAt;
  final Object? winnerId;
  final List<String> searchKeywords;
  final List<String> participantIds;

  // Added Settings & Scoring Logic Attributes
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
    this.maxTeams,
    this.membersPerTeam,
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

  /// Checks whether the competition has finished based on status or end date.
  bool get isFinished =>
      status.toLowerCase() == 'finished' ||
      status.toLowerCase() == 'completed' ||
      DateTime.now().isAfter(endDate);

  /// Fast, O(1) checking using `participantIds`,
  /// falling back safely to nested `participants` or `teams` if needed.
  bool isJoinedBy(String? userId) {
    if (userId == null || userId.isEmpty) return false;

    // 1. Direct O(1) look-up in flat participantIds list
    if (participantIds.contains(userId)) return true;

    // 2. Fallback check: Individual participants list
    if (participants != null && participants!.isNotEmpty) {
      final isParticipant = participants!.any((p) {
        if (p is String) return p == userId;
        try {
          return (p as dynamic).id == userId || (p as dynamic).userId == userId;
        } catch (_) {
          return false;
        }
      });
      if (isParticipant) return true;
    }

    // 3. Fallback check: Team members list
    if (teams != null && teams!.isNotEmpty) {
      final isTeamMember = teams!.any((t) {
        try {
          final members = (t as dynamic).members as List?;
          return members?.any((m) {
                if (m is String) return m == userId;
                return (m as dynamic).id == userId ||
                    (m as dynamic).userId == userId;
              }) ??
              false;
        } catch (_) {
          return false;
        }
      });
      if (isTeamMember) return true;
    }

    return false;
  }

  /// Creates a copy of the entity with updated field values.
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
    int? maxTeams,
    int? membersPerTeam,
    List<dynamic>? participants,
    List<dynamic>? teams,
    DateTime? createdAt,
    Object? winnerId,
    List<String>? searchKeywords,
    List<String>? participantIds,
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
      maxTeams: maxTeams ?? this.maxTeams,
      membersPerTeam: membersPerTeam ?? this.membersPerTeam,
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
        maxTeams,
        membersPerTeam,
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