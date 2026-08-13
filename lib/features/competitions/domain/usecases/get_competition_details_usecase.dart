import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/competition_repository.dart';

class GetCompetitionDetailsUseCase {
  final CompetitionRepository repository;

  GetCompetitionDetailsUseCase(this.repository);

  /// تم استخدام `call` لتسهيل استدعاء الـ UseCase كدالة مباشرة
  Future<CompetitionEntity> call(String competitionId) async {
    return await repository.getCompetitionDetails(competitionId);
  }
}