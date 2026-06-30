import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.isUser,
    required super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['name'] as String? ?? '',
      text: json['message'] as String? ?? '',
      isUser: true,
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

  Map<String, dynamic> toJson() => {
    'message': text,
  };
}
