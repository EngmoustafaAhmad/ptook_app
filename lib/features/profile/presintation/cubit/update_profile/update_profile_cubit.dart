import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ptook/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:ptook/features/profile/domain/usecases/upload_profile_avatar_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/sync_owner_competition_usecase.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';
import 'update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UploadProfileAvatarUseCase _uploadProfileAvatarUseCase;
  final SyncOwnerCompetitionsUseCase _syncOwnerCompetitionsUseCase;
  final ImagePicker _picker;

  XFile? _selectedAvatarFile;
  XFile? get selectedAvatarFile => _selectedAvatarFile;

  UpdateProfileCubit({
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required UploadProfileAvatarUseCase uploadProfileAvatarUseCase,
    required SyncOwnerCompetitionsUseCase syncOwnerCompetitionsUseCase,
    ImagePicker? picker,
  })  : _updateUserProfileUseCase = updateUserProfileUseCase,
        _uploadProfileAvatarUseCase = uploadProfileAvatarUseCase,
        _syncOwnerCompetitionsUseCase = syncOwnerCompetitionsUseCase,
        _picker = picker ?? ImagePicker(),
        super(const UpdateProfileInitial());

  /// Pick avatar image cross-platform
  Future<void> pickAvatarImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _selectedAvatarFile = pickedFile;
        _safeEmit(state);
      }
    } catch (e) {
      _safeEmit(UpdateProfileError("Failed to pick avatar: $e"));
    }
  }

  /// Clears current picked image selection
  void clearPickedAvatar() {
    _selectedAvatarFile = null;
    _safeEmit(state);
  }

  /// Submits updated profile information
  Future<void> updateProfile({
    required UserEntity currentUser,
    required String name,
    required String handle,
    String? bio,
  }) async {
    if (state is UpdateProfileLoading) return;

    _safeEmit(const UpdateProfileLoading());

    String updatedAvatarUrl = currentUser.avatarUrl ?? '';

    // Handle cross-platform avatar upload if a new avatar was picked
    if (_selectedAvatarFile != null) {
      try {
        final Uint8List bytes = await _selectedAvatarFile!.readAsBytes();
        final String fileExtension = _selectedAvatarFile!.name.contains('.')
            ? _selectedAvatarFile!.name.split('.').last
            : 'jpg';

        final uploadResult = await _uploadProfileAvatarUseCase(
          imageBytes: bytes,
          fileExtension: fileExtension,
          userId: currentUser.id,
        );

        bool uploadFailed = false;

        uploadResult.when(
          onSuccess: (url) {
            updatedAvatarUrl = url;
          },
          onFailure: (failure) {
            uploadFailed = true;
            _safeEmit(
              UpdateProfileError("Avatar upload failed: ${failure.message}"),
            );
          },
        );

        if (uploadFailed) return;
      } catch (e) {
        _safeEmit(UpdateProfileError("Failed to process avatar file: $e"));
        return;
      }
    }

    final trimmedName = name.trim();
    final finalAvatarUrl =
        updatedAvatarUrl.isNotEmpty ? updatedAvatarUrl : null;

    final updatedUser = currentUser.copyWith(
      name: trimmedName,
      handle: handle.trim().startsWith('@')
          ? handle.trim()
          : '@${handle.trim()}',
      bio: bio?.trim(),
      avatarUrl: finalAvatarUrl,
    );

    final result = await _updateUserProfileUseCase(updatedUser);

    await result.when(
      onSuccess: (_) async {
        // 🔄 Sync updated owner metadata across all owned competitions
        try {
          await _syncOwnerCompetitionsUseCase(
            ownerId: currentUser.id,
            ownerName: trimmedName,
            ownerAvatarUrl: finalAvatarUrl,
          );
        } catch (_) {
          // Fallback to preserve profile save if competition batch update encounters an issue
        }

        _selectedAvatarFile = null;
        _safeEmit(const UpdateProfileSuccess("Profile updated successfully!"));
      },
      onFailure: (failure) {
        _safeEmit(UpdateProfileError(failure.message));
      },
    );
  }

  void _safeEmit(UpdateProfileState newState) {
    if (!isClosed) emit(newState);
  }
}