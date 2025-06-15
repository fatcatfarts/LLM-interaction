import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/llm_repository.dart';
import '../auth_bloc/auth_bloc.dart';

part 'llm_event.dart';
part 'llm_state.dart';

class LlmBloc extends Bloc<LlmEvent, LlmState> {
  final LlmRepository llmRepository;
  final AuthBloc authBloc;
  List<ChatMessage> _chatHistory = [];

  LlmBloc({required this.llmRepository, required this.authBloc}) : super(LlmInitial()) {
    on<LlmSendPrompt>(_onSendPrompt);
    on<LlmStartNewChat>(_onStartNewChat);
  }

  Future<void> _onSendPrompt(LlmSendPrompt event, Emitter<LlmState> emit) async {
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.prompt,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    _chatHistory.add(userMessage);

    emit(LlmChatLoaded(List.from(_chatHistory)));
    emit(LlmLoading());

    try {
      final userToken = authBloc.currentUser?.token;
      final llmApiResponses = await llmRepository.sendPromptToBackend(
        prompt: event.prompt,
        userToken: userToken,
      );

      for (var apiResponse in llmApiResponses) {
        MessageSender sender = apiResponse.source.toLowerCase().contains("gemini")
            ? MessageSender.gemini
            : apiResponse.source.toLowerCase().contains("huggingface")
            ? MessageSender.huggingface
            : MessageSender.system;

        _chatHistory.add(ChatMessage(
          id: '${apiResponse.source}-${DateTime.now().millisecondsSinceEpoch}',
          text: apiResponse.content,
          sender: sender,
          timestamp: DateTime.now(),
        ));
      }
      emit(LlmChatLoaded(List.from(_chatHistory)));

    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Error: ${e.toString().replaceFirst("Exception: ", "")}',
        sender: MessageSender.system,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(errorMessage);
      emit(LlmChatLoaded(List.from(_chatHistory))); // Show error in chat

    }
  }

  void _onStartNewChat(LlmStartNewChat event, Emitter<LlmState> emit) {
    _chatHistory = [];
    emit(LlmInitial());
    emit(LlmChatLoaded(List.from(_chatHistory)));
  }
}