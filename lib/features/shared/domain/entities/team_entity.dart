import 'package:equatable/equatable.dart';
import 'participant_entity.dart';

class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String competitionId;
  final String ownerId;
  final String? avatarUrl; // 🖼️ Added avatarUrl field
  final String? joinCode;
  final bool isPrivate;
  final int totalPoints;
  final List<ParticipantEntity> members;
  final int membersCount;
  final int? maxMembers; // Nullable to support unlimited team sizes
  final DateTime? createdAt; // Nullable to safely handle null server timestamps

  const TeamEntity({
    required this.id,
    required this.name,
    required this.competitionId,
    required this.ownerId,
    this.avatarUrl,
    this.joinCode,
    this.isPrivate = false,
    this.totalPoints = 0,
    this.members = const [],
    this.membersCount = 0,
    this.maxMembers,
    this.createdAt,
  });

  /// Alias getter mapping joinCode as the password for UI consistency
  String? get password => joinCode;

  /// Calculates accumulated score across all team participants or defaults to totalPoints.
  int get calculatedTotalPoints =>
      members.isNotEmpty ? members.fold(0, (sum, member) => sum + (member.points ?? 0)) : totalPoints;

  /// Returns actual member count based on loaded list or server count.
  int get currentMemberCount => members.isNotEmpty ? members.length : membersCount;

  /// Checks whether the team has reached maximum member capacity.
  bool get isFull =>
      maxMembers != null && maxMembers! > 0 && currentMemberCount >= maxMembers!;

  /// Direct O(1) membership check for a given user ID.
  bool hasMember(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return members.any((member) => member.id == userId || member.userId == userId);
  }

  TeamEntity copyWith({
    String? id,
    String? name,
    String? competitionId,
    String? ownerId,
    String? avatarUrl,
    String? joinCode,
    bool? isPrivate,
    int? totalPoints,
    List<ParticipantEntity>? members,
    int? membersCount,
    int? maxMembers,
    DateTime? createdAt,
  }) {
    return TeamEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      competitionId: competitionId ?? this.competitionId,
      ownerId: ownerId ?? this.ownerId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinCode: joinCode ?? this.joinCode,
      isPrivate: isPrivate ?? this.isPrivate,
      totalPoints: totalPoints ?? this.totalPoints,
      members: members ?? this.members,
      membersCount: membersCount ?? this.membersCount,
      maxMembers: maxMembers ?? this.maxMembers,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        competitionId,
        ownerId,
        avatarUrl,
        joinCode,
        isPrivate,
        totalPoints,
        members,
        membersCount,
        maxMembers,
        createdAt,
      ];
}