import '../errors/failure.dart';

/// Explicit success/failure outcome used by repositories and use cases so
/// expected errors are typed values instead of thrown exceptions.
sealed class Result<T> {
  const Result();

  /// Folds the result into a single value.
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    return switch (self) {
      Success<T>(:final value) => success(value),
      Err<T>(failure: final f) => failure(f),
    };
  }
}

/// Successful outcome carrying [value].
final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

/// Failed outcome carrying a typed [failure].
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
