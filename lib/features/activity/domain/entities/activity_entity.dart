import 'package:equatable/equatable.dart';

enum ActivityType {
  powerEarned,        // ⚡ Earned power by watching ad
  powerSpent,         // ⚡ Spent power to perform action
  competitionJoined,  // 🏆 Joined competition or team
  competitionLeft,    // 🚪 Left competition or team
  competitionCreated, // 🚀 Created competition
  invitation,         // 🔖 Bookmarked / saved competition
  competitionWon
}

class ActivityEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final ActivityType type;
  final DateTime timestamp;
  final String? competitionId;
  final int? powerAmount;

  const ActivityEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.competitionId,
    this.powerAmount,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        type,
        timestamp,
        competitionId,
        powerAmount,
      ];
}