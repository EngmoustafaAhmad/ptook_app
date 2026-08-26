import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/create_competition_usecase.dart';
import 'create_competition_state.dart';

class CreateCompetitionCubit extends Cubit<CreateCompetitionState> {
  final CreateCompetitionUseCase _createCompetitionUseCase;
  final FirebaseAuth _auth;

  CreateCompetitionCubit({
    required CreateCompetitionUseCase createCompetitionUseCase,
    required FirebaseAuth auth,
  })  : _createCompetitionUseCase = createCompetitionUseCase,
        _auth = auth,
        super(const CreateCompetitionInitial());

  /// Submits the newly created competition after validating user session and input params.
  Future<void> submitCompetition({
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

    // Team settings
    int? maxTeams,
    int? membersPerTeam,
  }) async {
    _safeEmit(const CreateCompetitionLoading());

    final user = _auth.currentUser;
    if (user == null) {
      _safeEmit(const CreateCompetitionError("User not logged in"));
      return;
    }

    // Input Validation
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

    // Generate Private competition invite code
    final inviteCode = isPublic ? null : const Uuid().v4().substring(0, 8);
    final competitionId = const Uuid().v4();

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
      inviteCode: inviteCode,
      joinCode: joinCode?.trim(),
      category: category,
      searchKeywords: _generateSearchKeywords(name),
      participantIds: const {},
      participantsCount: 0,
      maxTeams: type == "team" ? maxTeams : null,
      maxTeamMembers: type == "team" ? membersPerTeam : null,
      createdAt: DateTime.now(),
      status: "upcoming",
      imageUrl: null,
      winnerId: null,
    );

    final result = await _createCompetitionUseCase(competition);

    switch (result) {
      case Success():
        _safeEmit(const CreateCompetitionSuccess());
      case Failure(:final message):
        _safeEmit(CreateCompetitionError(message));
    }
  }

  /// Resets the cubit state back to initial.
  void resetState() => _safeEmit(const CreateCompetitionInitial());

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
      if (maxTeams == null || maxTeams <= 0 || membersPerTeam == null || membersPerTeam <= 0) {
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