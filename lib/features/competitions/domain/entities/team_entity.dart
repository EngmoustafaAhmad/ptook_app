class TeamEntity {


  final String id;

  final String name;

  final String competitionId;

  final String ownerId;

  final String joinCode;

  final List<String> members;

  final DateTime createdAt;



  TeamEntity({
    required this.id,
    required this.name,
    required this.competitionId,
    required this.ownerId,
    required this.joinCode,
    required this.members,
    required this.createdAt,
  });
}