/// Sealed Result type for typed functional error handling across repositories.
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(AppException exception) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(data: final d) => d,
        Failure<T>() => null,
      };

  AppException? get exceptionOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(exception: final e) => e,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException exception) onFailure,
  }) {
    return switch (this) {
      Success<T>(data: final d) => onSuccess(d),
      Failure<T>(exception: final e) => onFailure(e),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}

/// Base domain exception with human-friendly user message
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic cause;

  const AppException(this.message, {this.code, this.cause});

  @override
  String toString() => 'AppException: $message ${code != null ? '($code)' : ''}';
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.cause});
}

class DeviceException extends AppException {
  const DeviceException(super.message, {super.code, super.cause});
}

class CommandException extends AppException {
  const CommandException(super.message, {super.code, super.cause});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.cause});
}
