import '../entities/chat_message.dart';

abstract class AiCoachRepository {
  Future<ChatMessage> sendMessage(String message);
  Future<List<ChatMessage>> getChatHistory();
  Future<String> getAnalysis();
  Future<List<String>> getRecommendations();
}
