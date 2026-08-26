import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import '../../domain/repositories/i_search_competition_repository.dart';
import '../datasources/i_search_competition_remote_data_source.dart';

class SearchCompetitionRepositoryImpl implements ISearchCompetitionRepository {
  final ISearchCompetitionRemoteDataSource _remoteDataSource;

  SearchCompetitionRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<CompetitionEntity>> streamAllCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _remoteDataSource.streamAllCompetitions(
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }

  @override
  Stream<List<CompetitionEntity>> streamSearchCompetitionsUseCase({
    required String query,
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _remoteDataSource.streamSearchCompetitions(
      query: query,
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }

  @override
  Stream<List<CompetitionEntity>> streamJoinedCompetitions({
    String? query,
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _remoteDataSource.streamJoinedCompetitions(
      query: query,
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }

  @override
  Stream<List<CompetitionEntity>> streamCreatedCompetitions({
    String? query,
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _remoteDataSource.streamCreatedCompetitions(
      query: query,
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }

  @override
  Future<Result<void>> joinCompetition({
    required String competitionId,
    required String userId,
    String? joinCode,
  }) async {
    try {
      await _remoteDataSource.joinCompetition(
        competitionId: competitionId,
        userId: userId,
        joinCode: joinCode,
      );
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> leaveCompetition(String competitionId) async {
    try {
      await _remoteDataSource.leaveCompetition(competitionId);
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> createCompetition(CompetitionEntity competition) async {
    try {
      final model = CompetitionModel.fromEntity(competition);
      await _remoteDataSource.createCompetition(model);
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> updateCompetition(CompetitionEntity competition) async {
    try {
      final model = CompetitionModel.fromEntity(competition);
      await _remoteDataSource.updateCompetition(model);
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteCompetition(String competitionId) async {
    try {
      await _remoteDataSource.deleteCompetition(competitionId);
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> finishCompetition(String competitionId) async {
    try {
      await _remoteDataSource.finishCompetition(competitionId);
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<CompetitionEntity?>> getCompetitionByCode(String code) async {
    try {
      final model = await _remoteDataSource.getCompetitionByCode(code);
      return Success(model);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<CompetitionEntity>> getCompetitionById(String competitionId) async {
    try {
      final model = await _remoteDataSource.getCompetitionById(competitionId);
      return Success(model);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<CompetitionEntity>> getCompetitionDetails(String competitionId) async {
    try {
      final model = await _remoteDataSource.getCompetitionDetails(competitionId);
      return Success(model);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<ParticipantEntity>>> getParticipants(
      String competitionId) async {
    try {
      final participants =
          await _remoteDataSource.getParticipants(competitionId);
      return Success(participants);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Stream<List<ParticipantEntity>> streamParticipants(String competitionId) {
    return _remoteDataSource.streamParticipants(competitionId);
  }

  @override
  Stream<List<TeamEntity>> streamTeams(String competitionId) {
    return _remoteDataSource.streamTeams(competitionId);
  }
}