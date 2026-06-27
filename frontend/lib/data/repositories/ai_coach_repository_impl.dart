import '../../core/constants/api_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_coach_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/chat_message_model.dart';

class AiCoachRepositoryImpl implements AiCoachRepository {
  final RemoteDataSource _remote;

  AiCoachRepositoryImpl(this._remote);

  @override
  Future<ChatMessage> sendMessage(String message) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.aiCoachChat,
      data: {'message': message},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return ChatMessageModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to send message');
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.aiCoachHistory,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load history');
  }

  @override
  Future<String> getAnalysis() async {
    final response = await _remote.get<Map<String, dynamic>>(
      ApiConstants.aiCoachAnalyze,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!['analysis'] as String? ?? '';
    }
    throw ApiException(message: response.message ?? 'Analysis failed');
  }

  @override
  Future<List<String>> getRecommendations() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.aiCoachRecommend,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!.map((e) => e as String).toList();
    }
    throw ApiException(message: response.message ?? 'Failed to get recommendations');
  }
}

