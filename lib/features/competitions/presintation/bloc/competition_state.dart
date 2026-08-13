import 'package:equatable/equatable.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';

abstract class CompetitionState extends Equatable {
  const CompetitionState();

  @override
  List<Object?> get props => [];
}

class CompetitionInitial extends CompetitionState {}

class CompetitionLoading extends CompetitionState {}

class CompetitionsLoaded extends CompetitionState {
  final List<CompetitionEntity> competitions;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const CompetitionsLoaded({
    required this.competitions,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  CompetitionsLoaded copyWith({
    List<CompetitionEntity>? competitions,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return CompetitionsLoaded(
      competitions: competitions ?? this.competitions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [competitions, hasReachedMax, isLoadingMore];
}

class CompetitionDetailsLoaded extends CompetitionState {
  final CompetitionEntity competition;

  const CompetitionDetailsLoaded(this.competition);

  @override
  List<Object?> get props => [competition];
}

class CompetitionActionSuccess extends CompetitionState {
  final String message;

  const CompetitionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CompetitionError extends CompetitionState {
  final String message;

  const CompetitionError(this.message);

  @override
  List<Object?> get props => [message];
}