import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/participant_entity.dart';

abstract class ParticipantManagementState extends Equatable {
  final List<ParticipantEntity> participants;

  const ParticipantManagementState({this.participants = const []});

  int get totalParticipants => participants.length;

  /// Getters for UI checks
  bool get isLoading => this is ParticipantManagementLoading;

  String? get errorMessage {
    if (this is ParticipantManagementFailure) {
      return (this as ParticipantManagementFailure).error;
    }
    return null;
  }

  @override
  List<Object?> get props => [participants];
}

class ParticipantManagementInitial extends ParticipantManagementState {
  const ParticipantManagementInitial();
}

class ParticipantManagementLoading extends ParticipantManagementState {
  const ParticipantManagementLoading({super.participants});
}

class ParticipantManagementLoaded extends ParticipantManagementState {
  const ParticipantManagementLoaded({required super.participants});

  ParticipantManagementLoaded copyWith({List<ParticipantEntity>? participants}) {
    return ParticipantManagementLoaded(
      participants: participants ?? this.participants,
    );
  }
}

class ParticipantActionSuccess extends ParticipantManagementState {
  final String message;

  const ParticipantActionSuccess(this.message, {super.participants});

  @override
  List<Object?> get props => [message, participants];
}

class ParticipantManagementFailure extends ParticipantManagementState {
  final String error;

  const ParticipantManagementFailure(this.error, {super.participants});

  @override
  List<Object?> get props => [error, participants];
}