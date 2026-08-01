import 'package:ptook/features/competitions/data/datasources/competition_remote_data_source.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';



class CompetitionRepositoryImpl 
    implements ICompetitionRepository {



  final ICompetitionRemoteDataSource remoteDataSource;



  CompetitionRepositoryImpl({
    required this.remoteDataSource,
  });





  @override
  Future<void> createCompetition(
      CompetitionEntity competition,
  ) async {

    await remoteDataSource.createCompetition(
      competition,
    );

  }





  @override
  Future<List<CompetitionEntity>>
  searchPublicCompetitions(
      String keyword,
  ) async {


    return await remoteDataSource
        .searchPublicCompetitions(
          keyword,
        );

  }
  
  @override
  Future<List<CompetitionEntity>> getPublicCompetitions() {
    throw UnimplementedError();
  }


}