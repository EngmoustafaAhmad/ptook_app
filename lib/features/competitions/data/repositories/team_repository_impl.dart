import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/i_team_repository.dart';
import '../datasources/team_remote_data_source.dart';
import '../models/team_model.dart';

class TeamRepositoryImpl implements ITeamRepository {
  final ITeamRemoteDataSource remoteDataSource;

  TeamRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<TeamEntity>> getTeams(String competitionId) async {
    // 🎯 الـ Remote Data Source ترجع List<TeamModel>
    // وبما أن TeamModel يورث من TeamEntity، يمكن إرجاعها مباشرة
    final teamModels = await remoteDataSource.getTeams(competitionId);
    return teamModels;
  }

  @override
  Future<void> createTeam(TeamEntity team) async {
    // 🎯 تحويل الـ TeamEntity إلى TeamModel قبل إرسالها للـ Data Source
    final teamModel = TeamModel.fromEntity(team);

    await remoteDataSource.createTeam(teamModel);
  }
}