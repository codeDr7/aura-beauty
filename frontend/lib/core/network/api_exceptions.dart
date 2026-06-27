class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({
    this.message = 'An unexpected error occurred.',
    this.statusCode,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException($statusCode): $message';
    }
    return 'ApiException: $message';
  }
}

class NetworkException extends ApiException {
  NetworkException({
    super.message = 'No internet connection available.',
    super.statusCode,
  });

  @override
  String toString() {
    return 'NetworkException: $message';
  }
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
  });

  @override
  String toString() {
    return 'UnauthorizedException(401): $message';
  }
}

class NotFoundException extends ApiException {
  NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
  });

  @override
  String toString() {
    return 'NotFoundException(404): $message';
  }
}

class ServerException extends ApiException {
  ServerException({
    super.message = 'Server error. Please try again later.',
    super.statusCode = 500,
  });

  @override
  String toString() {
    return 'ServerException($statusCode): $message';
  }
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException({
    super.message = 'Validation failed.',
    this.errors,
    super.statusCode = 422,
  });

  String get firstError {
    if (errors != null && errors!.isNotEmpty) {
      final firstField = errors!.entries.first;
      if (firstField.value.isNotEmpty) {
        return firstField.value.first;
      }
    }
    return message;
  }

  List<String> getErrorsForField(String field) {
    return errors?[field] ?? [];
  }

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final errorStrings = errors!.entries
          .map((e) => '${e.key}: ${e.value.join(', ')}')
          .join('; ');
      return 'ValidationException(422): $errorStrings';
    }
    return 'ValidationException(422): $message';
  }
}

class RateLimitException extends ApiException {
  final Duration? retryAfter;

  RateLimitException({
    super.message = 'Too many requests. Please slow down.',
    super.statusCode = 429,
    this.retryAfter,
  });

  @override
  String toString() {
    if (retryAfter != null) {
      return 'RateLimitException(429): $message Retry after ${retryAfter!.inSeconds}s';
    }
    return 'RateLimitException(429): $message';
  }
}

class CancelledException extends ApiException {
  CancelledException({
    super.message = 'Request was cancelled.',
  });

  @override
  String toString() {
    return 'CancelledException: $message';
  }
}
