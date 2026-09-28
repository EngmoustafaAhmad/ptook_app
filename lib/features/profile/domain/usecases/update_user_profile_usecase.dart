import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';
import 'package:ptook/features/profile/domain/repositories/i_profile_repository.dart';

class UpdateUserProfileUseCase {
  final IProfileRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<Result<void>> call(UserEntity user) async {
    if (user.name.trim().isEmpty) {
      return const Err(ServerFailure("Name cannot be empty."));
    }
    if (user.handle.trim().isEmpty) {
      return const Err(ServerFailure("Handle cannot be empty."));
    }
    return await _repository.updateUserProfile(user);
  }
}