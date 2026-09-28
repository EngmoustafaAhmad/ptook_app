import 'dart:typed_data';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/profile/domain/repositories/i_profile_repository.dart';

class UploadProfileAvatarUseCase {
  final IProfileRepository _repository;

  UploadProfileAvatarUseCase(this._repository);

  Future<Result<String>> call({
    required Uint8List imageBytes,
    required String fileExtension,
    required String userId,
  }) async {
    if (imageBytes.isEmpty) {
      return const Err(ServerFailure("Image file is empty."));
    }
    return await _repository.uploadAvatar(
      imageBytes: imageBytes,
      fileExtension: fileExtension,
      userId: userId,
    );
  }
}