// lib/features/competitions/presintation/cubit/create_competition_cubit.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/usecases/create_competition_usecase.dart';
import 'package:ptook/features/competitions/presintation/bloc/create_competition_state.dart';

class CreateCompetitionCubit extends Cubit<CreateCompetitionState> {
  final CreateCompetitionUseCase createCompetitionUseCase;

  CreateCompetitionCubit({required this.createCompetitionUseCase}) : super(CreateCompetitionInitial());

  Future<void> submitCompetition({
    required String name,
    required String description,
    required String type,
    required int totalPoints,
    required String endDate,
    required int maxParticipants,
    required bool isPublic,
  }) async {
    emit(CreateCompetitionLoading());
    
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";
    final competitionId = DateTime.now().millisecondsSinceEpoch.toString();

    final competition = CompetitionEntity(
      id: competitionId,
      name: name,
      description: description,
      type: type,
      totalPoints: totalPoints,
      endDate: endDate,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
      creatorId: currentUserId,
    );

    final result = await createCompetitionUseCase(competition);
    result.fold(
      (error) => emit(CreateCompetitionError(error)),
      (_) => emit(CreateCompetitionSuccess()),
    );
  }
}