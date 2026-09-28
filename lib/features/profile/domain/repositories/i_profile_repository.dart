import 'dart:typed_data';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';

abstract class IProfileRepository {
  /// Streams real-time updates for the target user profile
  Stream<Result<UserEntity>> streamUserProfile(String userId);

  /// Fetches a one-time snapshot of the user profile
  Future<Result<UserEntity>> getUserProfile(String userId);

  /// Updates profile metadata (Name, Handle, Bio)
  Future<Result<void>> updateUserProfile(UserEntity user);

  /// Uploads avatar image bytes to GitHub storage and updates user profile URL
  Future<Result<String>> uploadAvatar({
    required Uint8List imageBytes,
    required String fileExtension,
    required String userId,
  });
}