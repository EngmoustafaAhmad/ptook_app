class TeamEntity {


  final String id;

  final String competitionId;

  final String name;


  // Team invitation code
  final String joinCode;


  final String ownerId;


  final int membersCount;

  final int maxMembers;


  final List<String> members;


  final DateTime createdAt;



  TeamEntity({

    required this.id,

    required this.competitionId,

    required this.name,

    required this.joinCode,

    required this.ownerId,

    required this.membersCount,

    required this.maxMembers,

    required this.members,

    required this.createdAt,

  });


}