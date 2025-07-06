import '../models/chat_message_model.dart';

abstract class ChatbotState {}

class ChatbotInitial extends ChatbotState {}

class ChatbotLoaded extends ChatbotState {
  final List<ChatMessageModel> messages;
  ChatbotLoaded({required this.messages});
}

class ChatbotError extends ChatbotState {
  final String message;
  ChatbotError({required this.message});
}

class ChatbotShowQuestions extends ChatbotState {
  final List<String> questions;
  ChatbotShowQuestions({required this.questions});
}