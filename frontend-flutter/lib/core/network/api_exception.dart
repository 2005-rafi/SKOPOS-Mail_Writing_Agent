/// Typed exceptions for network and API failures.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.requestId,
    this.details,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final String? requestId;
  final Map<String, dynamic>? details;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, code: $code, message: $message, requestId: $requestId)';
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Unable to connect to the backend server. Please verify your connection.',
  });
}

class RequestTimeoutException extends ApiException {
  const RequestTimeoutException({
    super.message = 'The request timed out. The AI model took too long to respond.',
  });
}

class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    super.statusCode = 422,
    super.code = 'VALIDATION_FAILED',
    super.requestId,
    super.details,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Authentication failed. Please verify your API key.',
    super.statusCode = 401,
    super.code = 'UNAUTHORIZED',
    super.requestId,
  });
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access forbidden. You do not have permission for this request.',
    super.statusCode = 403,
    super.code = 'FORBIDDEN',
    super.requestId,
  });
}

class RateLimitException extends ApiException {
  const RateLimitException({
    super.message = 'Rate limit exceeded. Please wait a moment before trying again.',
    super.statusCode = 429,
    super.code = 'RATE_LIMIT_EXCEEDED',
    super.requestId,
  });
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Internal server error occurred. Please try again later.',
    super.statusCode = 500,
    super.code = 'INTERNAL_ERROR',
    super.requestId,
  });
}
