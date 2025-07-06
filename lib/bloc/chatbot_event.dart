abstract class ChatbotEvent {}

class ChatbotInitEvent extends ChatbotEvent {}

class SendMessageEvent extends ChatbotEvent {
  final String message;
  SendMessageEvent(this.message);
}

class ShowQuestionsEvent extends ChatbotEvent {}