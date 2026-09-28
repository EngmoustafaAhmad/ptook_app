import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';
import 'package:ptook/features/profile/domain/repositories/i_profile_repository.dart';

class StreamUserProfileUseCase {
  final IProfileRepository _repository;

  StreamUserProfileUseCase(this._repository);

  Stream<Result<UserEntity>> call(String userId) {
    return _repository.streamUserProfile(userId);
  }
}
