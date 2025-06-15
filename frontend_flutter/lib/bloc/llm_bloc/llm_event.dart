part of 'llm_bloc.dart';

abstract class LlmEvent extends Equatable {
  const LlmEvent();
  @override
  List<Object?> get props => [];
}

class LlmSendPrompt extends LlmEvent {
  final String prompt;

  const LlmSendPrompt({required this.prompt });
  @override
  List<Object?> get props => [prompt ];
}

class LlmStartNewChat extends LlmEvent {}
