import 'package:flutter/material.dart';
import '../../data/models/chat_message_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    bool isUserMessage = message.sender == MessageSender.user;
    bool isSystemError = message.sender == MessageSender.system && message.text.toLowerCase().startsWith('error:');

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
            color: isUserMessage
                ? Theme.of(context).primaryColor.withOpacity(0.9)
                : isSystemError
                ? Colors.red.shade100
                : Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16.0),
              topRight: const Radius.circular(16.0),
              bottomLeft: isUserMessage ? const Radius.circular(16.0) : const Radius.circular(0),
              bottomRight: isUserMessage ? const Radius.circular(0) : const Radius.circular(16.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              )
            ]
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUserMessage && message.sender != MessageSender.system)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.sender.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUserMessage ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: isUserMessage ? Colors.white : (isSystemError ? Colors.red.shade900 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}