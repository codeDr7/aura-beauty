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
    final response = await _remote.get<Map<String, dynamic>>(
      ApiConstants.analyzeNeeds,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return SkinAnalysisModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Analysis failed');
  }

  @override
  Future<List<SkinAnalysis>> getAnalysisHistory() async {
    throw ApiException(message: 'Not available');
  }

  @override
  Future<SkinAnalysis> getAnalysisById(String id) async {
    throw ApiException(message: 'Not available');
  }
}
