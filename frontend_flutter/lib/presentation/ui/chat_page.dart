import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/llm_bloc/llm_bloc.dart';
import '../../data/models/chat_message_model.dart';
import '../../routes/app_routes.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_promptController.text.trim().isNotEmpty) {
      context.read<LlmBloc>().add(LlmSendPrompt(prompt: _promptController.text.trim()));
      _promptController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LLM Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New Chat',
            onPressed: () {
              context.read<LlmBloc>().add(LlmStartNewChat());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<LlmBloc, LlmState>(
              listener: (context, state) {
                if (state is LlmChatLoaded || state is LlmResponsesReceived) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                }
              },
              builder: (context, state) {
                List<ChatMessage> messages = [];
                if (state is LlmChatLoaded) {
                  messages = state.messages;
                } else if (state is LlmResponsesReceived) {
                  messages = state.currentChatHistory;
                } else if (state is LlmInitial) {
                  messages = [];
                }

                if (state is LlmLoading && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (messages.isEmpty && state is! LlmLoading) {
                  return const Center(child: Text('Type a message to start chatting!'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length + (state is LlmLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (state is LlmLoading && index == messages.length) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      ));
                    }
                    final message = messages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'Enter your prompt...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}