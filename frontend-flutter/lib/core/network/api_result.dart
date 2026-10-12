import 'api_exception.dart';

/// Functional Result type representing either Success(data) or Failure(error).
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  T? get dataOrNull => switch (this) {
        ApiSuccess(:final data) => data,
        ApiFailure() => null,
      };

  ApiException? get errorOrNull => switch (this) {
        ApiSuccess() => null,
        ApiFailure(:final error) => error,
      };

  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(ApiException error) onFailure,
  }) {
    return switch (this) {
      ApiSuccess(:final data) => onSuccess(data),
      ApiFailure(:final error) => onFailure(error),
    };
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error);
  final ApiException error;
}
