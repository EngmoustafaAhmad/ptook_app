import 'package:equatable/equatable.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String competitionId;
  final String ownerId;
  final String? joinCode;
  final bool isPrivate;
  final int points;
  final List<ParticipantEntity> members;
  final int membersCount;
  final int maxMembers;
  final DateTime createdAt;

  const TeamEntity({
    required this.id,
    required this.name,
    required this.competitionId,
    required this.ownerId,
    this.joinCode,
    this.isPrivate = false,
    this.points = 0,
    this.members = const [],
    this.membersCount = 0,
    this.maxMembers = 0,
    required this.createdAt,
  });

  /// Alias getter mapping joinCode as the password for UI consistency
  String? get password => joinCode;

  /// Calculates accumulated score across all team participants.
  int get totalPoints =>
      members.isNotEmpty ? members.fold(0, (sum, member) => sum + member.points) : points;

  /// Checks whether the team has reached maximum member capacity.
  bool get isFull =>
      maxMembers > 0 && (membersCount >= maxMembers || members.length >= maxMembers);

  TeamEntity copyWith({
    String? id,
    String? name,
    String? competitionId,
    String? ownerId,
    String? joinCode,
    bool? isPrivate,
    int? points,
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
      joinCode: joinCode ?? this.joinCode,
      isPrivate: isPrivate ?? this.isPrivate,
      points: points ?? this.points,
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
        joinCode,
        isPrivate,
        points,
        members,
        membersCount,
        maxMembers,
        createdAt,
      ];
}