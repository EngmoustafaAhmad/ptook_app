import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/profile/domain/usecases/stream_user_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final StreamUserProfileUseCase _streamUserProfileUseCase;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _profileSubscription;

  ProfileCubit({
    required StreamUserProfileUseCase streamUserProfileUseCase,
  })  : _streamUserProfileUseCase = streamUserProfileUseCase,
        super(const ProfileInitial());

  void streamUserProfile(String userId) => watchProfile(userId);
  void loadUserProfile(String userId) => watchProfile(userId);

  void watchProfile(String userId) {
    if (userId.isEmpty) {
      emit(const ProfileError("Invalid User ID."));
      return;
    }

    emit(const ProfileLoading());
    stopStreaming(); // ⚡ Cancel existing active stream before starting a new one

    _profileSubscription = _streamUserProfileUseCase(userId).listen(
      (result) {
        result.when(
          onSuccess: (user) => _safeEmit(ProfileLoaded(user)),
          onFailure: (failure) => _safeEmit(ProfileError(failure.message)),
        );
      },
      onError: (error) {
        // ⚡ Ignore permission-denied errors triggered during logout cleanup
        if (error.toString().contains('permission-denied')) {
          debugPrint('ProfileCubit stream stopped due to sign-out.');
          return;
        }
        _safeEmit(ProfileError("Stream error: $error"));
      },
    );
  }

  /// ⚡ Safely cancels active Firestore profile stream listeners when logging out
  void stopStreaming() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
  }

  Future<void> getProfile(String userId) async {
    watchProfile(userId);
  }

  /// ⚡ Decrements 1 Power Unit atomically from the user's document in Firestore
  /// and automatically logs a 'powerSpent' activity.
  Future<bool> consumePower(
    String userId, {
    String? actionTitle,
    String? competitionId,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      final success = await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return false;

        final currentPower = (snapshot.data()?['totalPower'] as int?) ?? 0;
        if (currentPower <= 0) return false;

        transaction.update(userRef, {
          'totalPower': FieldValue.increment(-1),
        });
        return true;
      });

      if (success) {
        // ⚡ Automatically log the power consumption
        await _logActivity(
          userId: userId,
          title: 'Power Used ⚡',
          description: actionTitle ?? 'Spent 1 Power Unit to perform an action.',
          type: 'powerSpent',
          powerAmount: -1,
          competitionId: competitionId,
        );
      }

      return success;
    } catch (e) {
      debugPrint("Consume power failed: $e");
      return false;
    }
  }

  /// 📺 Increments 1 Power Unit in Firestore when an ad is watched
  /// and automatically logs a 'powerEarned' activity.
  Future<bool> rewardPower(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'totalPower': FieldValue.increment(1),
      });

      // ⚡ Automatically log the rewarded power
      await _logActivity(
        userId: userId,
        title: 'Power Claimed ⚡',
        description: 'Earned +1 Power Unit by watching a rewarded ad.',
        type: 'powerEarned',
        powerAmount: 1,
      );

      return true;
    } catch (e) {
      debugPrint("Failed to grant reward power: $e");
      return false;
    }
  }

  /// ⚡ Atomically rewards 1 power, consumes it, and writes both log events
  /// in a single batch so state stays perfectly synced.
  Future<bool> rewardAndConsumePower(
    String userId, {
    String? actionTitle,
    String? competitionId,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      final success = await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return false;

        // Atomically keep power net-neutral (Reward +1, Consume -1)
        transaction.update(userRef, {
          'totalPower': FieldValue.increment(0),
        });
        return true;
      });

      if (success) {
        final batch = _firestore.batch();

        // 1. Log Rewarded Ad Claim (+1 ⚡)
        final rewardDoc = _firestore.collection('activities').doc();
        batch.set(rewardDoc, {
          'userId': userId,
          'title': 'Power Claimed ⚡',
          'description': 'Earned +1 Power Unit by watching a rewarded ad.',
          'type': 'powerEarned',
          'timestamp': FieldValue.serverTimestamp(),
          'powerAmount': 1,
        });

        // 2. Log Action Consumption (-1 ⚡)
        final actionDoc = _firestore.collection('activities').doc();
        batch.set(actionDoc, {
          'userId': userId,
          'title': 'Power Used ⚡',
          'description': actionTitle ?? 'Spent 1 Power Unit to perform an action.',
          'type': 'powerSpent',
          'timestamp': FieldValue.serverTimestamp(),
          'powerAmount': -1,
          'competitionId': competitionId,
        });

        await batch.commit();
      }

      return success;
    } catch (e) {
      debugPrint("Atomic rewardAndConsume failed: $e");
      return false;
    }
  }

  /// Helper method to keep activity logging clean and modular
  Future<void> _logActivity({
    required String userId,
    required String title,
    required String description,
    required String type,
    required int powerAmount,
    String? competitionId,
  }) async {
    try {
      await _firestore.collection('activities').add({
        'userId': userId,
        'title': title,
        'description': description,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'powerAmount': powerAmount,
        'competitionId': ?competitionId,
      });
    } catch (e) {
      debugPrint("Failed to write activity log: $e");
    }
  }

  void _safeEmit(ProfileState newState) {
    if (!isClosed) emit(newState);
  }

  @override
  Future<void> close() {
    stopStreaming();
    return super.close();
  }
}