import 'package:equatable/equatable.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

enum ManageCompetitionStatus {
  initial,
  loading,
  loaded,
  actionInProgress,
  actionSuccess,
  finished,
  deleted,
  failure, 
  error,
}

class ManageCompetitionState extends Equatable {
  final ManageCompetitionStatus status;
  final CompetitionEntity? competition;
  final List<ParticipantEntity> participants;
  final String? errorMessage;
  final String? successMessage;

  const ManageCompetitionState({
    this.status = ManageCompetitionStatus.initial,
    this.competition,
    this.participants = const [],
    this.errorMessage,
    this.successMessage,
  });

  ManageCompetitionState copyWith({
    ManageCompetitionStatus? status,
    CompetitionEntity? competition,
    List<ParticipantEntity>? participants,
    String? errorMessage,
    String? successMessage,
  }) {
    return ManageCompetitionState(
      status: status ?? this.status,
      competition: competition ?? this.competition,
      participants: participants ?? this.participants,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        competition,
        participants,
        errorMessage,
        successMessage,
      ];
}