// lib/data/models/chat_message_model.dart
import 'package:equatable/equatable.dart';

enum MessageSender { user, gemini, huggingface, system }

class ChatMessage extends Equatable {
  final String id; // Could be a timestamp or a generated ID
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, text, sender, timestamp];
}

class LlmApiResponse extends Equatable {
  final String source; // "gemini", "huggingface"
  final String content;

  const LlmApiResponse({required this.source, required this.content});

  factory LlmApiResponse.fromJson(Map<String, dynamic> json) {
    return LlmApiResponse(
      source: json['source'] as String,
      content: json['content'] as String,
    );
  }

  @override
  List<Object?> get props => [source, content];
}