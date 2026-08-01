class CompetitionEntity {

  final String id;

  final String name;

  final String description;

  final String type; // individual / team

  final int totalPoints;

  final DateTime startDate;

  final DateTime endDate;

  final int maxParticipants;

  final bool isPublic;

  final String ownerId;

  final String? inviteCode;


  // Search
  final String category;

  final List<String> searchKeywords;


  // Team settings
  final int? maxTeams;

  final int? membersPerTeam;


  final int participantsCount;

  final DateTime createdAt;


  // Extra
  final String status;

  final String? imageUrl;

  final String? winnerId;



  CompetitionEntity({

    required this.id,

    required this.name,

    required this.description,

    required this.type,

    required this.totalPoints,

    required this.startDate,

    required this.endDate,

    required this.maxParticipants,

    required this.isPublic,

    required this.ownerId,

    required this.searchKeywords,

    required this.category,

    this.maxTeams,

    this.membersPerTeam,

    required this.participantsCount,

    required this.createdAt,

    this.inviteCode,

    required this.status,

    this.imageUrl,

    this.winnerId,

  });

}