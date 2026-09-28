import 'dart:typed_data';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/services/github_storage_service.dart';

class UploadCompetitionImageUseCase {
  final GithubStorageService _storageService;

  UploadCompetitionImageUseCase(this._storageService);

  Future<Result<String>> call({
    required Uint8List imageBytes,
    required String fileExtension,
    required String competitionId,
  }) async {
    try {
      if (imageBytes.isEmpty) {
        return const Err(ServerFailure("Selected image is empty."));
      }

      final fileName = '${competitionId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      final imageUrl = await _storageService.uploadCompetitionImage(
        fileBytes: imageBytes,
        fileName: fileName,
      );

      if (imageUrl != null && imageUrl.isNotEmpty) {
        return Success(imageUrl);
      } else {
        // Return a clearer error message pointing to GitHub credentials/network issues
        return const Err(
          ServerFailure(
            "Failed to upload image to GitHub repository. Check your GitHub PAT token, repository permissions, or storage configuration.",
          ),
        );
      }
    } catch (e) {
      return Err(ServerFailure("An error occurred during image upload: $e"));
    }
  }
}