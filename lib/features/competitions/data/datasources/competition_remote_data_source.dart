import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';



abstract class ICompetitionRemoteDataSource {


  Future<void> createCompetition(
      CompetitionEntity competition
  );


  Future<List<CompetitionModel>> searchPublicCompetitions(
      String keyword
  );


}




class CompetitionRemoteDataSourceImpl
    implements ICompetitionRemoteDataSource {


  final FirebaseFirestore firestore;



  CompetitionRemoteDataSourceImpl({

    required this.firestore,

  });



  @override
  Future<void> createCompetition(
      CompetitionEntity competition
  ) async {



    final model = CompetitionModel(


      id: competition.id,


      name: competition.name,


      description: competition.description,


      type: competition.type,


      totalPoints:
      competition.totalPoints,



      startDate:
      competition.startDate,



      endDate:
      competition.endDate,



      maxParticipants:
      competition.maxParticipants,



      isPublic:
      competition.isPublic,



      ownerId:
      competition.ownerId,



      inviteCode:
      competition.inviteCode,



      category:
      competition.category,



      searchKeywords:
      generateSearchKeywords(
        competition.name,
        competition.description,
      ),



      maxTeams:
      competition.maxTeams,



      membersPerTeam:
      competition.membersPerTeam,



      participantsCount:
      competition.participantsCount,



      createdAt:
      competition.createdAt,



      status:
      competition.status,



      imageUrl:
      competition.imageUrl,



      winnerId:
      competition.winnerId,


    );



    await firestore

        .collection('competitions')

        .doc(model.id)

        .set(

          model.toJson(),

        );

  }







  @override
  Future<List<CompetitionModel>> searchPublicCompetitions(

      String keyword,

  ) async {



    final snapshot = await firestore

        .collection('competitions')


        .where(

          'isPublic',

          isEqualTo: true,

        )


        .where(

          'searchKeywords',

          arrayContains: keyword.toLowerCase(),

        )


        .limit(20)


        .get();





    return snapshot.docs.map((doc){


      return CompetitionModel.fromJson(

        {

          'id':doc.id,

          ...doc.data(),

        },

      );


    }).toList();


  }







  List<String> generateSearchKeywords(

      String name,

      String description,

  ){


    final text =

        "$name $description"

            .toLowerCase();



    return text

        .split(

          RegExp(r'\s+'),

        )


        .where(

          (word)=>word.isNotEmpty,

        )


        .toSet()


        .toList();


  }



}