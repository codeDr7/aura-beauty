import 'dart:convert';
import 'dart:math';
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
          ApiConstants.headerHost: ApiConstants.hostHeader,
          ApiConstants.headerXAppVersion: ApiConstants.appVersion,
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
        final apiKey = await _storage.read(key: ApiConstants.storageKeyApiKey);
        final apiSecret = await _storage.read(key: ApiConstants.storageKeyApiSecret);
        if (apiKey != null && apiKey.isNotEmpty && apiSecret != null && apiSecret.isNotEmpty) {
          options.headers[ApiConstants.headerAuthorization] = 'token $apiKey:$apiSecret';
        }

        options.headers[ApiConstants.headerXDeviceId] = await _ensureDeviceId();

        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 403) {
          await clearTokens();
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

  String _extractServerMessage(Map<String, dynamic> data) {
    try {
      final serverMessages = data['_server_messages'] as String?;
      if (serverMessages != null && serverMessages.isNotEmpty) {
        final messages = jsonDecode(serverMessages) as List<dynamic>;
        if (messages.isNotEmpty) {
          final firstMsg = jsonDecode(messages.first as String) as Map<String, dynamic>;
          return firstMsg['message'] as String? ?? '';
        }
      }
    } catch (_) {}
    return '';
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
          final bodyStatusCode = data['http_status_code'] as int? ?? statusCode;

          String message = _extractServerMessage(data);
          if (message.isEmpty) {
            final exc = data['exception'] as String?;
            if (exc != null && exc.contains(':')) {
              message = exc.split(':').last.trim();
            } else {
              message = exc ?? 'An unexpected error occurred.';
            }
          }

          switch (bodyStatusCode) {
            case 400:
              return ValidationException(message: message, statusCode: 400);
            case 401:
              return UnauthorizedException(message: message, statusCode: 401);
            case 403:
              return UnauthorizedException(message: message, statusCode: 403);
            case 404:
              return NotFoundException(message: message, statusCode: 404);
            case 409:
              return ValidationException(message: message, statusCode: 409);
            case 422:
              return ValidationException(message: message, statusCode: 422);
            case 429:
              return NetworkException(
                message: 'Too many requests. Please try again later.',
                statusCode: 429,
              );
            case >= 500:
              return ServerException(message: 'Server error. Please try again later.', statusCode: bodyStatusCode);
            default:
              return ApiException(message: message, statusCode: bodyStatusCode);
          }
        }
        return ApiException(message: 'An unexpected error occurred.', statusCode: statusCode);
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.', statusCode: null);
      default:
        return ApiException(message: 'An unexpected error occurred.', statusCode: null);
    }
  }

  Future<String> _ensureDeviceId() async {
    final existing = await _storage.read(key: ApiConstants.storageKeyDeviceId);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final random = Random();
    const chars = 'abcdef0123456789';
    final id = List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
    await _storage.write(key: ApiConstants.storageKeyDeviceId, value: id);
    return id;
  }

  Future<void> setApiCredentials(String apiKey, String apiSecret) async {
    await _storage.write(key: ApiConstants.storageKeyApiKey, value: apiKey);
    await _storage.write(key: ApiConstants.storageKeyApiSecret, value: apiSecret);
  }

  Future<Map<String, String>?> getApiCredentials() async {
    final apiKey = await _storage.read(key: ApiConstants.storageKeyApiKey);
    final apiSecret = await _storage.read(key: ApiConstants.storageKeyApiSecret);
    if (apiKey != null && apiSecret != null) {
      return {'api_key': apiKey, 'api_secret': apiSecret};
    }
    return null;
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

    T? _tryTransform(dynamic raw) {
      if (fromJson == null) return null;
      try {
        return fromJson(raw);
      } catch (_) {
        return null;
      }
    }

    T? _safeCast(dynamic raw) {
      try {
        return raw as T?;
      } catch (_) {
        return null;
      }
    }

    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        final responseData = data['message'];
        if (responseData == null) {
          return ApiResponse.success(data: null, statusCode: response.statusCode);
        }
        final transformed = _tryTransform(responseData);
        if (transformed != null) {
          return ApiResponse.success(data: transformed, statusCode: response.statusCode);
        }
        return ApiResponse.success(data: _safeCast(responseData), statusCode: response.statusCode);
      }

      if (data.containsKey('data')) {
        final responseData = data['data'];
        final transformed = _tryTransform(responseData);
        if (transformed != null) {
          return ApiResponse.success(data: transformed, statusCode: response.statusCode);
        }
        return ApiResponse.success(data: _safeCast(responseData), statusCode: response.statusCode);
      }

      final transformed = _tryTransform(data);
      if (transformed != null) {
        return ApiResponse.success(data: transformed, statusCode: response.statusCode);
      }
      return ApiResponse.success(data: _safeCast(data), statusCode: response.statusCode);
    }

    if (fromJson != null && data != null) {
      try {
        return ApiResponse.success(data: fromJson(data), statusCode: response.statusCode);
      } catch (_) {}
    }
    return ApiResponse.success(data: _safeCast(data), statusCode: response.statusCode);
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

  Future<void> clearTokens() async {
    await _storage.delete(key: ApiConstants.storageKeyApiKey);
    await _storage.delete(key: ApiConstants.storageKeyApiSecret);
    await _storage.delete(key: ApiConstants.storageKeyDeviceId);
  }
}
