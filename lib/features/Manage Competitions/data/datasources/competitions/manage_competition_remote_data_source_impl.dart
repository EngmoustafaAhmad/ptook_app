import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/competitions/i_manage_competition_remote_data_source.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';

class ManageCompetitionRemoteDataSourceImpl
    implements IManageCompetitionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ManageCompetitionRemoteDataSourceImpl({
    required this.firestore,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      firestore.collection('competitions');

  @override
  Future<void> updateCompetition(CompetitionModel competition) async {
    try {
      await _competitionsRef.doc(competition.id).update(competition.toJson());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update competition');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteCompetition(String competitionId) async {
    try {
      final compRef = _competitionsRef.doc(competitionId);
      
      // Fetch subcollections
      final participantsSnapshot = await compRef.collection('participants').get();
      final teamsSnapshot = await compRef.collection('teams').get();

      // Collect all references to delete
      List<DocumentReference> docsToDelete = [];
      docsToDelete.add(compRef);

      for (var doc in participantsSnapshot.docs) {
        docsToDelete.add(doc.reference);
      }

      for (var teamDoc in teamsSnapshot.docs) {
        docsToDelete.add(teamDoc.reference);
        final membersSnapshot = await teamDoc.reference.collection('members').get();
        for (var memberDoc in membersSnapshot.docs) {
          docsToDelete.add(memberDoc.reference);
        }
      }

      // Commit in chunks of 450 to safely respect Firestore's 500 batch limit
      for (var i = 0; i < docsToDelete.length; i += 450) {
        final batch = firestore.batch();
        final chunk = docsToDelete.skip(i).take(450);
        
        for (var docRef in chunk) {
          batch.delete(docRef);
        }
        
        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete competition');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> finishCompetition(String competitionId) async {
    try {
      await _competitionsRef.doc(competitionId).update({
        'status': 'completed',
        'endDate': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to finish competition');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<CompetitionModel> streamCompetition(String competitionId) {
    return _competitionsRef
        .doc(competitionId)
        .snapshots()
        .where((doc) => doc.exists && doc.data() != null)
        .map((doc) => _mapDocToModel(doc));
  }

  CompetitionModel _mapDocToModel(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw const ServerException('Competition document contains no data');
    }
    return CompetitionModel.fromJson(
      data,
      id: doc.id,
    );
  }
}