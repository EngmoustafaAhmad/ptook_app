import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/competition_entity.dart';
import '../../domain/usecases/create_competition_usecase.dart';
import 'create_competition_state.dart';

class CreateCompetitionCubit extends Cubit<CreateCompetitionState> {
  final CreateCompetitionUseCase createCompetitionUseCase;
  final FirebaseAuth auth;

  CreateCompetitionCubit({
    required this.createCompetitionUseCase,
    required this.auth,
  }) : super(CreateCompetitionInitial());

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

    // Team settings
    int? maxTeams,
    int? membersPerTeam,
  }) async {
    _safeEmit(CreateCompetitionLoading());

    try {
      final user = auth.currentUser;

      if (user == null) {
        _safeEmit(CreateCompetitionError("User not logged in"));
        return;
      }

      // Validation
      if (type == "team") {
        if (maxTeams == null || membersPerTeam == null) {
          _safeEmit(CreateCompetitionError("Team settings are required"));
          return;
        }
      } else {
        if (maxParticipants <= 0) {
          _safeEmit(CreateCompetitionError("Maximum participants required"));
          return;
        }
      }

      // Private competition invite code
      String? inviteCode;
      if (!isPublic) {
        inviteCode = const Uuid().v4().substring(0, 8);
      }

      final competitionId = const Uuid().v4();

      // Build Competition Entity
      final competition = CompetitionEntity(
        id: competitionId,
        name: name,
        description: description,
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
        category: category,
        searchKeywords: _generateSearchKeywords(name),
        
        // Starts with 0 participants
        participantIds: const [],
        participantsCount: 0,

        // Team settings
        maxTeams: type == "team" ? maxTeams : null,
        membersPerTeam: type == "team" ? membersPerTeam : null,

        createdAt: DateTime.now(),
        status: "upcoming",
        imageUrl: null,
        winnerId: null,
      );

      await createCompetitionUseCase(competition);

      _safeEmit(CreateCompetitionSuccess());
    } catch (e) {
      _safeEmit(CreateCompetitionError(_formatErrorMessage(e)));
    }
  }

  void _safeEmit(CreateCompetitionState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  List<String> _generateSearchKeywords(String name) {
    final List<String> keywords = [];
    final lowerName = name.toLowerCase().trim();

    for (int i = 1; i <= lowerName.length; i++) {
      keywords.add(lowerName.substring(0, i));
    }
    return keywords;
  }

  String _formatErrorMessage(dynamic error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message.isEmpty ? 'An error occurred while creating the competition.' : message;
  }
}