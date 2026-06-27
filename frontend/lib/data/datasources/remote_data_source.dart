import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';

class RemoteDataSource {
  final ApiClient _api;

  RemoteDataSource(this._api);

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) {
    return _api.get(path, queryParameters: queryParameters, fromJson: fromJson);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) {
    return _api.post(path, data: data, fromJson: fromJson);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) {
    return _api.put(path, data: data, fromJson: fromJson);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) {
    return _api.delete(path, data: data, fromJson: fromJson);
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    String fieldName = 'file',
    T Function(dynamic json)? fromJson,
  }) {
    return _api.uploadFile(path, filePath: filePath, fieldName: fieldName, fromJson: fromJson);
  }
}
