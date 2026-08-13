import 'package:equatable/equatable.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

abstract class CompetitionHomeState extends Equatable {
  const CompetitionHomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when screen is first opened
class CompetitionHomeInitial extends CompetitionHomeState {}

/// General loading state (e.g., initial page load)
class CompetitionHomeLoading extends CompetitionHomeState {}

/// Loaded state containing competition & participant details
class CompetitionHomeLoaded extends CompetitionHomeState {
  final CompetitionEntity competition;
  final List<ParticipantEntity> participants;
  final bool isFavorite;
  final bool isActionLoading; // For non-blocking actions like join/leave

  const CompetitionHomeLoaded({
    required this.competition,
    required this.participants,
    this.isFavorite = false,
    this.isActionLoading = false,
  });

  /// Allows updating specific state properties seamlessly without rebuilding the entire object
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