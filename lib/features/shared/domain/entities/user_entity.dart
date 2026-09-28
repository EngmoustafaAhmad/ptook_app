import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String handle; // e.g., "@ahmed_traveler"
  final String? bio;
  final String? avatarUrl;

  // Profile Stats
  final int totalPower; // ⚡ Power consumed/earned across competitions
  final int joinedCompetitionsCount; // 🏆 Count of active & completed competitions
  final int savedCompetitionsCount; // 🔖 Bookmarked competitions count

  final Set<String> savedCompetitionIds;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.handle,
    this.bio,
    this.avatarUrl,
    this.totalPower = 3, // ⚡ Initial registration bonus
    this.joinedCompetitionsCount = 0,
    this.savedCompetitionsCount = 0,
    this.savedCompetitionIds = const {},
    required this.createdAt,
  });

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Allows setting nullable values explicitly to null using optional parameters.
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? handle,
    Object? bio = _undefined,
    Object? avatarUrl = _undefined,
    int? totalPower,
    int? joinedCompetitionsCount,
    int? savedCompetitionsCount,
    Set<String>? savedCompetitionIds,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      handle: handle ?? this.handle,
      bio: bio == _undefined ? this.bio : bio as String?,
      avatarUrl: avatarUrl == _undefined ? this.avatarUrl : avatarUrl as String?,
      totalPower: totalPower ?? this.totalPower,
      joinedCompetitionsCount:
          joinedCompetitionsCount ?? this.joinedCompetitionsCount,
      savedCompetitionsCount:
          savedCompetitionsCount ?? this.savedCompetitionsCount,
      savedCompetitionIds: savedCompetitionIds ?? this.savedCompetitionIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        handle,
        bio,
        avatarUrl,
        totalPower,
        joinedCompetitionsCount,
        savedCompetitionsCount,
        savedCompetitionIds,
        createdAt,
      ];
}

// Sentinel marker to distinguish explicit nulls from unpassed values in copyWith
const Object _undefined = Object();