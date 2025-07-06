import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/chatbot_service.dart';
import '../models/chat_message_model.dart';
import 'chatbot_event.dart';
import 'chatbot_state.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final ChatbotService _service;

  ChatbotBloc(this._service) : super(ChatbotInitial()) {
    on<ChatbotInitEvent>(_onInit);
    on<SendMessageEvent>(_onSendMessage);
    on<ShowQuestionsEvent>(_onShowQuestions);
  }

  Future<void> _onInit(ChatbotInitEvent event, Emitter<ChatbotState> emit) async {
    final welcomeMessage = await _service.getWelcomeMessage();
    emit(ChatbotLoaded(messages: [welcomeMessage]));
    add(ShowQuestionsEvent());
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatbotState> emit) async {
    if (state is ChatbotLoaded) {
      final currentMessages = (state as ChatbotLoaded).messages;
      final userMessage = ChatMessageModel(text: event.message, isUser: true);
      emit(ChatbotLoaded(messages: [...currentMessages, userMessage]));
      final loadingMessage = ChatMessageModel(text: 'Loading...', isUser: false);
      emit(ChatbotLoaded(messages: [...currentMessages, userMessage, loadingMessage]));
      try {
        final response = await _service.getBotResponse(event.message);
        final suggestions = await _service.getDynamicSuggestions(event.message);
        final botMessage = ChatMessageModel(
          text: response,
          isUser: false,
          suggestions: suggestions,
        );
        emit(ChatbotLoaded(messages: [...currentMessages, userMessage, botMessage]));
      } catch (e) {
        emit(ChatbotError(message: 'Error processing your request.'));
      }
    }
  }

  Future<void> _onShowQuestions(ShowQuestionsEvent event, Emitter<ChatbotState> emit) async {
    if (state is ChatbotLoaded) {
      emit(ChatbotShowQuestions(questions: _service.getQuestions()));
    }
  }
}