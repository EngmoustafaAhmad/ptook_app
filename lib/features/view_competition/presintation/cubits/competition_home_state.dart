import 'package:equatable/equatable.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';

abstract class CompetitionHomeState extends Equatable {
  const CompetitionHomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when screen is first opened
class CompetitionHomeInitial extends CompetitionHomeState {
  const CompetitionHomeInitial();
}

/// Loading state for initial fetch
class CompetitionHomeLoading extends CompetitionHomeState {
  const CompetitionHomeLoading();
}

/// Main loaded state holding single screen data
class CompetitionHomeLoaded extends CompetitionHomeState {
  final CompetitionEntity competition;
  final List<ParticipantEntity> participants;
  final bool isFavorite;
  final bool isActionLoading;

  CompetitionHomeLoaded({
    required this.competition,
    required this.participants,
    bool? isFavorite,
    this.isActionLoading = false,
  }) : isFavorite = isFavorite ?? competition.isFavorite;

  CompetitionHomeLoaded copyWith({
    CompetitionEntity? competition,
    List<ParticipantEntity>? participants,
    bool? isFavorite,
    bool? isActionLoading,
  }) {
    return CompetitionHomeLoaded(
      competition: competition ?? this.competition,
      participants: participants ?? this.participants,
      isFavorite: isFavorite ?? this.isFavorite,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [
        competition,
        participants,
        isFavorite,
        isActionLoading,
      ];
}

/// State holding the list of saved/favorited competitions
class SavedCompetitionsLoaded extends CompetitionHomeState {
  final List<CompetitionEntity> competitions;

  const SavedCompetitionsLoaded({
    required this.competitions,
  });

  SavedCompetitionsLoaded copyWith({
    List<CompetitionEntity>? competitions,
  }) {
    return SavedCompetitionsLoaded(
      competitions: competitions ?? this.competitions,
    );
  }

  @override
  List<Object?> get props => [competitions];
}

/// Error state for handling network or business errors
class CompetitionHomeError extends CompetitionHomeState {
  final String message;

  const CompetitionHomeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Success state for one-time events (SnackBars, Navigation)
class CompetitionHomeActionSuccess extends CompetitionHomeState {
  final String message;

  const CompetitionHomeActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}