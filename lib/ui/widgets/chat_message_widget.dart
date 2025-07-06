import 'package:flutter/material.dart';
import '../../models/chat_message_model.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessageModel message;
  final Function(String) onSuggestionTap;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: message.isUser
                  ? const Color(0xff457B9D).withOpacity(0.8)
                  : const Color(0xffF0E5CF).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 16.0,
                color: message.isUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (message.suggestions != null && !message.isUser) ...[
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: message.suggestions!.map((suggestion) {
                return OutlinedButton(
                  onPressed: () => onSuggestionTap(suggestion),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xff457B9D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: const TextStyle(color: Color(0xff457B9D), fontSize: 14.0),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}