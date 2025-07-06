import 'dart:math';
import 'package:string_similarity/string_similarity.dart';
import '../models/chat_message_model.dart';
import '../utils/extensions.dart';

class ChatbotService {
  final List<String> _previousQuestions = [];
  final List<String> _randomGreetings = [
    'Hello! Nice to see you! How can I help?',
    'Hi there! What’s on your mind today?',
    'Hey! I’m here to assist—ask me anything!',
  ];

  final Map<String, String> _qaDatabase = {
    'How do I book an appointment?': 'You can book an appointment through the "Appointments" section. Choose a doctor and select a time slot for either an online session (via voice/video call) or an in-clinic visit.',
    'What are the payment methods?': 'We support secure payments via credit/debit cards, PayPal, and cash payments at the clinic. All transactions are encrypted for your safety.',
    'How do I view my profile?': 'Navigate to the "Profile" section to view your medical history, past sessions, prescribed medications, and notes from your doctor.',
    'What are reminders?': 'The app sends notifications to remind you of your upcoming appointments and medication schedules. You can customize reminder settings in the app.',
    'What is the 12-step program?': 'The 12-step program is a structured support plan to help you achieve mental wellness goals through daily tasks and reflections.',
    'How do I access the library or podcasts?': 'Visit the "Library" section to access articles, videos, and podcasts on mental health topics, curated by our experts.',
    'How can I learn about medication side effects?': 'Go to the "Medications" section to search for your prescribed drugs and view detailed information about their uses and potential side effects.',
    'How do I rate my doctor?': 'After each session, you’ll be prompted to rate your doctor and provide feedback in the "Sessions" section.',
    'What are the clinic’s operating hours?': 'Clinic hours vary by location, but most operate from 9 AM to 6 PM. Check the "Clinics" section for specific hours and contact details.'
  };

  final Map<String, List<String>> _suggestedQuestions = {
    'How do I book an appointment?': [
      'What are the clinic’s operating hours?',
      'How do I rate my doctor?'
    ],
    'What are the payment methods?': [
      'How do I book an appointment?',
      'How do I view my profile?'
    ],
    'How do I view my profile?': [
      'How can I learn about medication side effects?',
      'What are reminders?'
    ],
    'What are reminders?': [
      'How do I view my profile?',
      'How do I book an appointment?'
    ],
    'What is the 12-step program?': [
      'How do I access the library or podcasts?',
      'How can I learn about medication side effects?'
    ],
    'How do I access the library or podcasts?': [
      'What is the 12-step program?',
      'How can I learn about medication side effects?'
    ],
    'How can I learn about medication side effects?': [
      'How do I view my profile?',
      'What is the 12-step program?'
    ],
    'How do I rate my doctor?': [
      'How do I book an appointment?',
      'How do I view my profile?'
    ],
    'What are the clinic’s operating hours?': [
      'How do I book an appointment?',
      'What are the payment methods?'
    ],
  };

  final Map<String, List<String>> _keywordSynonyms = {
    'appointment': ['book', 'schedule', 'visit', 'reserve'],
    'payment': ['pay', 'cost', 'billing', 'charge'],
    'profile': ['account', 'details', 'info'],
    'reminder': ['notification', 'alert'],
    'program': ['12-step', 'plan', 'steps'],
    'library': ['resources', 'podcasts', 'articles'],
    'medication': ['drug', 'medicine', 'side effect'],
    'doctor': ['physician', 'rate', 'feedback'],
    'hours': ['open', 'clinic', 'timing'],
  };

  Future<ChatMessageModel> getWelcomeMessage() async {
    final random = Random().nextInt(_randomGreetings.length);
    return ChatMessageModel(
      text: '${_randomGreetings[random]} You can tap "Show Questions" to pick from a list, or type keywords like "appointment," "payment," "profile," "schedule," or "feedback" to get quick answers. What would you like to know?',
      isUser: false,
    );
  }

  Future<String> getBotResponse(String userInput) async {
    String inputLower = userInput.toLowerCase().trim();
    final random = Random();

    if (inputLower.containsAny(['hi', 'hello', 'hey', 'can i ask'])) {
      return '${_randomGreetings[random.nextInt(_randomGreetings.length)]} What’s on your mind today? Feel free to ask anything!';
    }

    if (_qaDatabase.containsKey(userInput)) {
      _previousQuestions.add(userInput);
      return _qaDatabase[userInput]! +
          (_previousQuestions.contains(userInput) ? ' You asked this before—need more details?' : '');
    }

    String? bestMatch;
    double bestScore = 0.0;
    for (var question in _qaDatabase.keys) {
      double score = question.toLowerCase().similarityTo(inputLower);
      if (score > bestScore && score > 0.5) {
        bestScore = score;
        bestMatch = question;
      }
    }

    if (bestMatch != null) {
      _previousQuestions.add(bestMatch);
      return _qaDatabase[bestMatch]! +
          (_previousQuestions.contains(bestMatch) ? ' You asked this before—need more details?' : '');
    }

    for (var keyword in _keywordSynonyms.keys) {
      if (_keywordSynonyms[keyword]!.any((synonym) => inputLower.contains(synonym))) {
        String response = '';
        if (keyword == 'appointment') {
          response = 'To book an appointment, go to the "Appointments" section. Choose a doctor and pick a time for an online or in-clinic visit.';
        } else if (keyword == 'payment') {
          response = 'We offer secure payment options including credit/debit cards, PayPal, and cash at the clinic.';
        } else if (keyword == 'profile') {
          response = 'You can view your medical history and session details in the "Profile" section.';
        } else if (keyword == 'reminder') {
          response = 'The app sends reminders for appointments and medications. You can customize them in the settings.';
        } else if (keyword == 'program') {
          response = 'The 12-step program helps you achieve mental wellness through daily tasks.';
        } else if (keyword == 'library') {
          response = 'Access articles, videos, and podcasts in the "Library" section.';
        } else if (keyword == 'medication') {
          response = 'You can learn about medication side effects in the "Medications" section.';
        } else if (keyword == 'doctor') {
          response = 'You can rate your doctor after each session in the "Sessions" section.';
        } else if (keyword == 'hours') {
          response = 'Clinic hours are typically 9 AM to 6 PM, but vary by location.';
        }
        _previousQuestions.add(response);
        return response +
            (_previousQuestions.contains(response) ? ' You checked this earlier—any other questions?' : '');
      }
    }

    if (!inputLower.containsAny([..._keywordSynonyms.values.expand((x) => x), ..._keywordSynonyms.keys, 'hi', 'hello', 'hey', 'ask'])) {
      return 'Sorry, this topic is not available in the context of mental health or clinic services. Please ask questions related to appointments, payments, your profile, or mental health.';
    }

    return 'Sorry, I didn’t understand that. Please try asking about appointments, payments, your profile, or mental health.';
  }

  Future<List<String>> getDynamicSuggestions(String userInput) async {
    if (_previousQuestions.isEmpty) {
      return _qaDatabase.keys.take(3).toList();
    }
    final lastQuestion = _previousQuestions.last;
    return _suggestedQuestions[lastQuestion] ?? _qaDatabase.keys.take(3).toList();
  }

  List<String> getQuestions() {
    return _qaDatabase.keys.toList();
  }
}