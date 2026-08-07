class ParticipantEntity {


  final String userId;

  final String competitionId;


  // competitor or owner
  final String role;


  // null if individual competition
  // team id if team competition
  final String? teamId;


  final int points;


  final DateTime joinedAt;



  ParticipantEntity({

    required this.userId,

    required this.competitionId,

    required this.role,

    this.teamId,

    required this.points,

    required this.joinedAt,

  });


}