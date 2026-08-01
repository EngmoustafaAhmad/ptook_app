import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/competition_entity.dart';
import '../../domain/usecases/search_public_competitions_usecase.dart';

part 'search_competition_state.dart';



class SearchCompetitionCubit 
    extends Cubit<SearchCompetitionState> {


  final SearchPublicCompetitionsUseCase
      searchPublicCompetitionsUseCase;



  SearchCompetitionCubit({
    required this.searchPublicCompetitionsUseCase,
  }) : super(SearchCompetitionInitial());





  Future<void> search(String keyword) async {


    // Don't search empty text
    if(keyword.trim().isEmpty){

      emit(
        SearchCompetitionInitial(),
      );

      return;

    }



    emit(
      SearchCompetitionLoading(),
    );



    try {


      final competitions =
          await searchPublicCompetitionsUseCase(
            keyword.toLowerCase(),
          );



      emit(

        SearchCompetitionSuccess(
          competitions,
        ),

      );



    } catch(e){


      emit(

        SearchCompetitionError(
          e.toString(),
        ),

      );


    }


  }


}