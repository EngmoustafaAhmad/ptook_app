class CompetitionEntity {
  final String id;
  final String name;
  final String description;
  final String type; // individual or team
  final int totalPoints;
  final String endDate;
  final int maxParticipants;
  final bool isPublic;
  final String ownerId;

  CompetitionEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.totalPoints,
    required this.endDate,
    required this.maxParticipants,
    required this.isPublic,
    required this.ownerId,
  });
}