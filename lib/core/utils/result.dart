import 'package:ptook/core/errors/failures.dart';

sealed class Result<T> {
  const Result();

  /// Pattern matching method for handling both branches
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success(data: final data) => onSuccess(data),
      Err(failure: final failure) => onFailure(failure),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);

  /// Helper getter to access the error message directly without unwrapping
  String get message => failure.message;
}