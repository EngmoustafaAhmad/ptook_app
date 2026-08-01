import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/competition_entity.dart';
import '../../domain/usecases/get_public_competitions_usecase.dart';


part 'search_competition_state.dart';


class SearchCompetitionCubit 
    extends Cubit<SearchCompetitionState> {


  final GetPublicCompetitionsUseCase getPublicCompetitionsUseCase;


  SearchCompetitionCubit({
    required this.getPublicCompetitionsUseCase,
  }) : super(SearchCompetitionInitial());



  Future<void> loadPublicCompetitions() async {


    emit(
      SearchCompetitionLoading(),
    );


    try {


      final competitions =
          await getPublicCompetitionsUseCase();



      emit(
        SearchCompetitionSuccess(
          competitions,
        ),
      );


    } catch (e) {


      emit(
        SearchCompetitionError(
          e.toString(),
        ),
      );


    }


  }

}