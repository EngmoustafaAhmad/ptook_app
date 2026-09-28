import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/features/activity/domain/entities/activity_entity.dart';

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.type,
    required super.timestamp,
    super.competitionId,
    super.powerAmount,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return ActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ActivityType.powerEarned,
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      competitionId: data['competitionId'],
      powerAmount: data['powerAmount'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.name,
      'timestamp': FieldValue.serverTimestamp(),
      'competitionId': competitionId,
      'powerAmount': powerAmount,
    };
  }
}