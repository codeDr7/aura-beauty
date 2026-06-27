class ApiResponse<T> {
  final bool isSuccess;
  final String message;
  final T? data;
  final int? statusCode;

  const ApiResponse({
    required this.isSuccess,
    this.message = '',
    this.data,
    this.statusCode,
  });

  factory ApiResponse.success({
    T? data,
    String message = '',
    int? statusCode,
  }) {
    return ApiResponse(
      isSuccess: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure({
    String message = 'An unexpected error occurred.',
    int? statusCode,
  }) {
    return ApiResponse(
      isSuccess: false,
      message: message,
      data: null,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromJson,
  }) {
    final status = json['status'] as String? ?? 'success';
    final isSuccess = status == 'success';
    final message = json['message'] as String? ?? '';
    final rawData = json['data'];

    T? data;
    if (rawData != null && fromJson != null) {
      data = fromJson(rawData);
    } else if (rawData != null) {
      data = rawData as T?;
    }

    return ApiResponse(
      isSuccess: isSuccess,
      message: message,
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': isSuccess ? 'success' : 'error',
      'message': message,
      'data': data,
    };
  }

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message) onFailure,
  }) {
    if (isSuccess && data != null) {
      return onSuccess(data!);
    }
    return onFailure(message);
  }

  ApiResponse<S> map<S>(S Function(T data) transform) {
    if (isSuccess && data != null) {
      return ApiResponse.success(
        data: transform(data!),
        message: message,
        statusCode: statusCode,
      );
    }
    return ApiResponse.failure(
      message: message,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(isSuccess: $isSuccess, message: $message, data: $data, statusCode: $statusCode)';
  }
}
