import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
          ApiConstants.headerAcceptLanguage: 'en',
        },
      ),
    );

    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_errorInterceptor());
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));
  }

  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(
          key: ApiConstants.storageKeyAccessToken,
        );
        if (token != null && token.isNotEmpty) {
          options.headers[ApiConstants.headerAuthorization] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final retryResponse = await _retry(error.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final exception = _parseError(error);
        handler.next(DioException(
          requestOptions: error.requestOptions,
          error: exception,
          response: error.response,
          type: error.type,
        ));
      },
    );
  }

  ApiException _parseError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timed out. Please check your internet.',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return NetworkException(
          message: 'No internet connection available.',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (data is Map<String, dynamic>) {
          final message = data['message'] as String? ??
              data['error'] as String? ??
              'An unexpected error occurred.';
          final errors = data['errors'] as Map<String, List<String>>?;

          switch (statusCode) {
            case 400:
              return ValidationException(
                message: message,
                errors: errors,
                statusCode: statusCode,
              );
            case 401:
              return UnauthorizedException(
                message: message,
                statusCode: statusCode,
              );
            case 404:
              return NotFoundException(
                message: message,
                statusCode: statusCode,
              );
            case 422:
              return ValidationException(
                message: message,
                errors: errors,
                statusCode: statusCode,
              );
            case 429:
              return NetworkException(
                message: 'Too many requests. Please try again later.',
                statusCode: statusCode,
              );
            case >= 500:
              return ServerException(
                message: 'Server error. Please try again later.',
                statusCode: statusCode,
              );
            default:
              return ApiException(
                message: message,
                statusCode: statusCode,
              );
          }
        }
        return ApiException(
          message: 'An unexpected error occurred.',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          statusCode: null,
        );
      default:
        return ApiException(
          message: 'An unexpected error occurred.',
          statusCode: null,
        );
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(
        key: ApiConstants.storageKeyRefreshToken,
      );
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _storage.write(
          key: ApiConstants.storageKeyAccessToken,
          value: data['access_token'] as String,
        );
        await _storage.write(
          key: ApiConstants.storageKeyRefreshToken,
          value: data['refresh_token'] as String,
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await _storage.read(
      key: ApiConstants.storageKeyAccessToken,
    );
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        ApiConstants.headerAuthorization: 'Bearer $token',
      },
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? extraFields,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (extraFields != null) ...extraFields,
      });
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            ApiConstants.headerContentType: ApiConstants.contentTypeMultipart,
          },
        ),
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<T>> uploadMultipleFiles<T>(
    String path, {
    required List<String> filePaths,
    String fieldName = 'files',
    Map<String, dynamic>? extraFields,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final files = await Future.wait(
        filePaths.map((p) => MultipartFile.fromFile(p)),
      );
      final formData = FormData.fromMap({
        fieldName: files,
        if (extraFields != null) ...extraFields,
      });
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            ApiConstants.headerContentType: ApiConstants.contentTypeMultipart,
          },
        ),
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic json)? fromJson,
  ) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final status = data['status'] as String? ?? 'success';
      final message = data['message'] as String? ?? '';
      final responseData = data['data'] ?? data;

      if (fromJson != null && responseData != null) {
        return ApiResponse.success(
          data: fromJson(responseData),
          message: message,
        );
      }
      return ApiResponse.success(
        data: responseData as T?,
        message: message,
      );
    }
    return ApiResponse.success(data: data as T?);
  }

  ApiResponse<T> _handleDioError<T>(DioException error) {
    final exception = error.error;
    if (exception is ApiException) {
      return ApiResponse.failure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    }
    return ApiResponse.failure(
      message: 'An unexpected error occurred.',
    );
  }

  void updateLanguage(String languageCode) {
    _dio.options.headers[ApiConstants.headerAcceptLanguage] = languageCode;
  }

  void updateBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  Future<void> setToken(String token) async {
    await _storage.write(
      key: ApiConstants.storageKeyAccessToken,
      value: token,
    );
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(
      key: ApiConstants.storageKeyRefreshToken,
      value: token,
    );
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: ApiConstants.storageKeyAccessToken);
    await _storage.delete(key: ApiConstants.storageKeyRefreshToken);
  }

  Future<String?> getToken() async {
    return _storage.read(key: ApiConstants.storageKeyAccessToken);
  }
}
