import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/competition_entity.dart';

enum ManageCompetitionStatus {
  initial,
  loading,
  loaded,
  actionSuccess,
  finished,
  deleted,
  failure, actionInProgress,
}

abstract class ManageCompetitionState extends Equatable {
  final CompetitionEntity? competition;

  const ManageCompetitionState({this.competition});

  /// Status enum getter for UI state checks
  ManageCompetitionStatus get status {
    if (this is ManageCompetitionInitial) return ManageCompetitionStatus.initial;
    if (this is ManageCompetitionLoading) return ManageCompetitionStatus.loading;
    if (this is ManageCompetitionLoaded) return ManageCompetitionStatus.loaded;
    if (this is ManageCompetitionActionSuccess) return ManageCompetitionStatus.actionSuccess;
    if (this is ManageCompetitionFinished) return ManageCompetitionStatus.finished;
    if (this is ManageCompetitionDeleted) return ManageCompetitionStatus.deleted;
    if (this is ManageCompetitionFailure) return ManageCompetitionStatus.failure;
    return ManageCompetitionStatus.initial;
  }

  /// Convenience getters
  bool get isLoading => this is ManageCompetitionLoading;
  bool get isFinished => competition?.status.toLowerCase() == 'finished';

  /// Helper to get error message if state is Failure
  String? get errorMessage {
    if (this is ManageCompetitionFailure) {
      return (this as ManageCompetitionFailure).error;
    }
    return null;
  }

  /// Helper to get success message across action states
  String? get successMessage {
    if (this is ManageCompetitionActionSuccess) {
      return (this as ManageCompetitionActionSuccess).message;
    }
    if (this is ManageCompetitionFinished) {
      return (this as ManageCompetitionFinished).message;
    }
    if (this is ManageCompetitionDeleted) {
      return (this as ManageCompetitionDeleted).message;
    }
    return null;
  }

  @override
  List<Object?> get props => [competition];
}

class ManageCompetitionInitial extends ManageCompetitionState {
  const ManageCompetitionInitial();
}

class ManageCompetitionLoading extends ManageCompetitionState {
  const ManageCompetitionLoading({super.competition});
}

class ManageCompetitionLoaded extends ManageCompetitionState {
  const ManageCompetitionLoaded({required super.competition});

  ManageCompetitionLoaded copyWith({CompetitionEntity? competition}) {
    return ManageCompetitionLoaded(
      competition: competition ?? this.competition,
    );
  }
}

class ManageCompetitionActionSuccess extends ManageCompetitionState {
  final String message;

  const ManageCompetitionActionSuccess(
    this.message, {
    super.competition,
  });

  @override
  List<Object?> get props => [message, competition];
}

class ManageCompetitionFinished extends ManageCompetitionState {
  final String? message;

  const ManageCompetitionFinished({
    this.message,
    super.competition,
  });

  @override
  List<Object?> get props => [message, competition];
}

class ManageCompetitionDeleted extends ManageCompetitionState {
  final String? message;

  const ManageCompetitionDeleted({this.message});

  @override
  List<Object?> get props => [message];
}

class ManageCompetitionFailure extends ManageCompetitionState {
  final String error;

  const ManageCompetitionFailure(
    this.error, {
    super.competition,
  });

  @override
  List<Object?> get props => [error, competition];
}