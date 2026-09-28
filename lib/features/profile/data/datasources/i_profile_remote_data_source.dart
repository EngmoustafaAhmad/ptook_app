import 'package:ptook/features/shared/data/models/user_model.dart';

abstract class IProfileRemoteDataSource {
  Stream<UserModel> streamUserProfile(String userId);
  Future<UserModel> getUserProfile(String userId);
  Future<void> updateUserProfile(UserModel userModel);
}