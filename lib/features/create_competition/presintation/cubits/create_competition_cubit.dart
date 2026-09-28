import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/create_competition_usecase.dart';
import '../../domain/usecases/upload_competition_image_usecase.dart';
import 'create_competition_state.dart';

class CreateCompetitionCubit extends Cubit<CreateCompetitionState> {
  final CreateCompetitionUseCase _createCompetitionUseCase;
  final UploadCompetitionImageUseCase? _uploadCompetitionImageUseCase;
  final FirebaseAuth _auth;
  final ImagePicker _picker;

  XFile? _selectedImageFile;
  XFile? get selectedImageFile => _selectedImageFile;

  CreateCompetitionCubit({
    required CreateCompetitionUseCase createCompetitionUseCase,
    UploadCompetitionImageUseCase? uploadCompetitionImageUseCase,
    required FirebaseAuth auth,
    ImagePicker? picker,
  })  : _createCompetitionUseCase = createCompetitionUseCase,
        _uploadCompetitionImageUseCase = uploadCompetitionImageUseCase,
        _auth = auth,
        _picker = picker ?? ImagePicker(),
        super(const CreateCompetitionInitial());

  /// Handles picking an image from the gallery (Cross-Platform)
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _selectedImageFile = pickedFile;
        _safeEmit(state);
      }
    } catch (e) {
      _safeEmit(CreateCompetitionError("Failed to pick image: $e"));
    }
  }

  /// Clears the picked image file
  void clearImage() {
    _selectedImageFile = null;
    _safeEmit(state);
  }

  /// Submits the newly created competition
  Future<void> submitCompetition({
    required String status,
    required String name,
    required String description,
    required String type,
    required int totalPoints,
    required DateTime startDate,
    required DateTime endDate,
    required int maxParticipants,
    required bool isPublic,
    required String category,
    String? joinCode,
    String? linkUrl,

    // Team settings
    int? maxTeams,
    int? membersPerTeam,
  }) async {
    if (state is CreateCompetitionLoading) return;

    _safeEmit(const CreateCompetitionLoading());

    final user = _auth.currentUser;
    if (user == null) {
      _safeEmit(const CreateCompetitionError("User not logged in"));
      return;
    }

    final validationError = _validateInput(
      name: name,
      type: type,
      startDate: startDate,
      endDate: endDate,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
      joinCode: joinCode,
      maxTeams: maxTeams,
      membersPerTeam: membersPerTeam,
    );

    if (validationError != null) {
      _safeEmit(CreateCompetitionError(validationError));
      return;
    }

    final inviteCode = isPublic ? null : const Uuid().v4().substring(0, 8);
    final competitionId = const Uuid().v4();

    String? imageUrl;

    // Handle Cross-Platform Image Upload
    if (_selectedImageFile != null && _uploadCompetitionImageUseCase != null) {
      try {
        final Uint8List imageBytes = await _selectedImageFile!.readAsBytes();
        final String fileExtension = _selectedImageFile!.name.contains('.')
            ? _selectedImageFile!.name.split('.').last
            : 'jpg';

        final uploadResult = await _uploadCompetitionImageUseCase!(
          imageBytes: imageBytes,
          fileExtension: fileExtension,
          competitionId: competitionId,
        );

        uploadResult.when(
          onSuccess: (url) {
            imageUrl = url;
          },
          onFailure: (failure) {
            _safeEmit(
              CreateCompetitionError(
                "Image upload failed: ${failure.message}",
              ),
            );
          },
        );
      } catch (e) {
        _safeEmit(CreateCompetitionError("Failed to process image file: $e"));
      }

      if (state is CreateCompetitionError) return;
    }

    // 👤 Extract current user's profile metadata
    final String ownerName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : 'Organizer';
    final String? ownerAvatarUrl = user.photoURL;

    final competition = CompetitionEntity(
      id: competitionId,
      name: name.trim(),
      description: description.trim(),
      type: type,
      totalPoints: totalPoints,
      startDate: startDate,
      endDate: endDate,
      maxParticipants: type == "individual"
          ? maxParticipants
          : (maxTeams! * membersPerTeam!),
      isPublic: isPublic,
      ownerId: user.uid,
      ownerName: ownerName,             // 👈 Passes creator's display name
      ownerAvatarUrl: ownerAvatarUrl,   // 👈 Passes creator's avatar URL
      inviteCode: inviteCode,
      joinCode: joinCode?.trim(),
      category: category,
      searchKeywords: _generateSearchKeywords(name),
      participantIds: const {},
      participantsCount: 0,
      maxTeams: type == "team" ? maxTeams : null,
      maxTeamMembers: type == "team" ? membersPerTeam : null,
      createdAt: DateTime.now(),
      status: status,
      imageUrl: imageUrl,
      linkUrl: linkUrl?.trim(),
      winnerId: null,
    );

    final result = await _createCompetitionUseCase(competition);

    result.when(
      onSuccess: (_) {
        _selectedImageFile = null; // Clean up image reference on success
        _safeEmit(const CreateCompetitionSuccess());
      },
      onFailure: (failure) {
        _safeEmit(CreateCompetitionError(failure.message));
      },
    );
  }

  void resetState() {
    _selectedImageFile = null;
    _safeEmit(const CreateCompetitionInitial());
  }

  String? _validateInput({
    required String name,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required int maxParticipants,
    required bool isPublic,
    String? joinCode,
    int? maxTeams,
    int? membersPerTeam,
  }) {
    if (name.trim().isEmpty) {
      return "Competition name cannot be empty";
    }

    if (endDate.isBefore(startDate)) {
      return "End date cannot be before start date";
    }

    if (!isPublic && (joinCode == null || joinCode.trim().isEmpty)) {
      return "Join code is required for private competitions";
    }

    if (type == "team") {
      if (maxTeams == null ||
          maxTeams <= 0 ||
          membersPerTeam == null ||
          membersPerTeam <= 0) {
        return "Valid team settings are required for team competitions";
      }
    } else {
      if (maxParticipants <= 0) {
        return "Maximum participants must be greater than zero";
      }
    }

    return null;
  }

  List<String> _generateSearchKeywords(String name) {
    final List<String> keywords = [];
    final lowerName = name.toLowerCase().trim();

    for (int i = 1; i <= lowerName.length; i++) {
      keywords.add(lowerName.substring(0, i));
    }
    return keywords;
  }

  void _safeEmit(CreateCompetitionState newState) {
    if (!isClosed) emit(newState);
  }
}