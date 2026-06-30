import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.isUser,
    required super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {bool isUser = true}) {
    return ChatMessageModel(
      id: json['name'] as String? ?? '',
      text: (isUser ? json['message'] : json['response']) as String? ?? '',
      isUser: isUser,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  factory ChatMessageModel.fromResponse(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['name'] as String? ?? '',
      text: json['response'] as String? ?? '',
      isUser: false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  static List<ChatMessage> fromHistoryEntry(Map<String, dynamic> json) {
    final ts = json['timestamp'] != null
        ? DateTime.parse(json['timestamp'] as String)
        : DateTime.now();
    return [
      ChatMessageModel(
        id: json['name'] as String? ?? '',
        text: json['message'] as String? ?? '',
        isUser: true,
        timestamp: ts,
      ),
      ChatMessageModel(
        id: json['name'] as String? ?? '',
        text: json['response'] as String? ?? '',
        isUser: false,
        timestamp: ts,
      ),
    ];
  }

  Map<String, dynamic> toJson() => {
    'message': text,
  };
}
