// lib/bloc/llm_bloc/llm_state.dart
part of 'llm_bloc.dart';

abstract class LlmState extends Equatable {
  const LlmState();
  @override
  List<Object?> get props => [];
}

class LlmInitial extends LlmState {}

class LlmLoading extends LlmState {}

class LlmChatLoaded extends LlmState {
  final List<ChatMessage> messages;
  const LlmChatLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class LlmResponsesReceived extends LlmState {
  final List<ChatMessage> currentChatHistory;
  final List<LlmApiResponse> llmOptions;

  const LlmResponsesReceived(this.currentChatHistory, this.llmOptions);

  @override
  List<Object?> get props => [currentChatHistory, llmOptions];
}


class LlmError extends LlmState {
  final String message;
  const LlmError(this.message);
  @override
  List<Object?> get props => [message];
}