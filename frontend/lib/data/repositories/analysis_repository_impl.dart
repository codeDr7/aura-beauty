import '../../core/constants/api_constants.dart';
import '../../domain/entities/skin_analysis.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/skin_analysis_model.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final RemoteDataSource _remote;

  AnalysisRepositoryImpl(this._remote);

  @override
  Future<SkinAnalysis> analyzeSkin({String? imagePath}) async {
    if (imagePath != null) {
      final response = await _remote.uploadFile<Map<String, dynamic>>(
        ApiConstants.uploadImage,
        filePath: imagePath,
        fieldName: 'image',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      if (response.isSuccess && response.data != null) {
        return SkinAnalysisModel.fromJson(response.data!);
      }
      throw ApiException(message: response.message ?? 'Analysis failed');
    }
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.aiCoachAnalyze,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return SkinAnalysisModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Analysis failed');
  }

  @override
  Future<List<SkinAnalysis>> getAnalysisHistory() async {
    final response = await _remote.get<List<dynamic>>(
      '${ApiConstants.aiCoachAnalyze}/history',
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => SkinAnalysisModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load history');
  }

  @override
  Future<SkinAnalysis> getAnalysisById(String id) async {
    final response = await _remote.get<Map<String, dynamic>>(
      '${ApiConstants.aiCoachAnalyze}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return SkinAnalysisModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Analysis not found');
  }
}

