import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/usecases/create_competition_usecase.dart';

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
  required String endDate,
  required int maxParticipants,
  required bool isPublic,

}) async {

  emit(CreateCompetitionLoading());


  try {

    // ✅ Add safety check here
    final user = auth.currentUser;


    if (user == null) {

      emit(
        CreateCompetitionError(
          "User not logged in",
        ),
      );

      return;
    }


    // Create competition object
    final competition = CompetitionEntity(

      id: const Uuid().v4(),

      name: name,

      description: description,

      type: type,

      totalPoints: totalPoints,

      endDate: endDate,

      maxParticipants: maxParticipants,

      isPublic: isPublic,

      // ✅ Now it is safe
      ownerId: user.uid,

    );


    await createCompetitionUseCase(
      competition,
    );


    emit(
      CreateCompetitionSuccess(),
    );


  } catch(e) {

    emit(
      CreateCompetitionError(
        e.toString(),
      ),
    );

  }

}
}