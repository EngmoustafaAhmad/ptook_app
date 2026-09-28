import 'dart:typed_data';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/profile/data/datasources/i_profile_remote_data_source.dart';
import 'package:ptook/features/shared/data/models/user_model.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';
import 'package:ptook/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:ptook/services/github_storage_service.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileRemoteDataSource _remoteDataSource;
  final GithubStorageService _storageService;

  ProfileRepositoryImpl({
    required IProfileRemoteDataSource remoteDataSource,
    required GithubStorageService storageService,
  })  : _remoteDataSource = remoteDataSource,
        _storageService = storageService;

  @override
  Stream<Result<UserEntity>> streamUserProfile(String userId) {
    return _remoteDataSource
        .streamUserProfile(userId)
        .map<Result<UserEntity>>((model) => Success(model.toEntity()))
        .handleError((error) => Err(ServerFailure(error.toString())));
  }

  @override
  Future<Result<UserEntity>> getUserProfile(String userId) async {
    try {
      final userModel = await _remoteDataSource.getUserProfile(userId);
      return Success(userModel.toEntity());
    } catch (e) {
      return Err(ServerFailure("Failed to load profile: $e"));
    }
  }

  @override
  Future<Result<void>> updateUserProfile(UserEntity user) async {
    try {
      final model = UserModel.fromEntity(user);
      await _remoteDataSource.updateUserProfile(model);
      return const Success(null);
    } catch (e) {
      return Err(ServerFailure("Failed to update profile: $e"));
    }
  }

  @override
  Future<Result<String>> uploadAvatar({
    required Uint8List imageBytes,
    required String fileExtension,
    required String userId,
  }) async {
    try {
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      final avatarUrl = await _storageService.uploadUserAvatar(
        fileBytes: imageBytes,
        fileName: fileName,
      );

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        return Success(avatarUrl);
      }
      return const Err(ServerFailure("Avatar upload to storage failed."));
    } catch (e) {
      return Err(ServerFailure("Failed to upload avatar: $e"));
    }
  }
}