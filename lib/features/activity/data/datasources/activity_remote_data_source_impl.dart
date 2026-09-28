import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/features/activity/data/datasources/i_activity_remote_data_source.dart';
import 'package:ptook/features/activity/data/models/activity_model.dart';

class ActivityRemoteDataSourceImpl implements IActivityRemoteDataSource {
  final FirebaseFirestore firestore;

  ActivityRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<ActivityModel>> streamUserActivities(String userId) {
    return firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> logActivity(ActivityModel model) async {
    await firestore.collection('activities').add(model.toFirestore());
  }
}