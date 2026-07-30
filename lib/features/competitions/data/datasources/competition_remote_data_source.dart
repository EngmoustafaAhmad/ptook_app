import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';


abstract class ICompetitionRemoteDataSource {

  Future<void> createCompetition(
      CompetitionEntity competition
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
      totalPoints: competition.totalPoints,
      endDate: competition.endDate,
      maxParticipants: competition.maxParticipants,
      isPublic: competition.isPublic,
      ownerId: competition.ownerId,
    );


  await firestore
      .collection('competitions')
      .doc(model.id)
      .set(model.toJson());

  }

}