import '../entities/skin_analysis.dart';

abstract class AnalysisRepository {
  Future<SkinAnalysis> analyzeSkin({String? imagePath});
  Future<List<SkinAnalysis>> getAnalysisHistory();
  Future<SkinAnalysis> getAnalysisById(String id);
}
