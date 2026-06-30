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
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.analyzeNeeds,
      data: imagePath != null ? {'image_path': imagePath} : {},
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
      ApiConstants.getAssessmentHistory,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => SkinAnalysisModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load assessment history');
  }

  @override
  Future<SkinAnalysis> getAnalysisById(String id) async {
    final history = await getAnalysisHistory();
    final match = history.where((a) => a.id == id).toList();
    if (match.isNotEmpty) return match.first;
    throw ApiException(message: 'Analysis not found');
  }
}
