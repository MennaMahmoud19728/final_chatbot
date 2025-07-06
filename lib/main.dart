import 'package:flutter/material.dart';
import 'dart:math';
import 'package:string_similarity/string_similarity.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatbotScreen(),
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
        cardTheme: CardTheme(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final List<String> _previousQuestions = [];
  final List<String> _randomGreetings = [
    'Hello! Nice to see you! How can I help?',
    'Hi there! What’s on your mind today?',
    'Hey! I’m here to assist—ask me anything!',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addWelcomeMessage();
      _showQuestionsSheet(context);
    });
  }

  // Database of questions and answers
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

  // Suggested questions for each topic
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

  // Keyword synonyms for NLP
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

  // Add welcome message
  void _addWelcomeMessage() {
    final random = Random().nextInt(_randomGreetings.length);
    setState(() {
      _messages.add(ChatMessage(
        text: '${_randomGreetings[random]} You can tap "Show Questions" to pick from a list, or type keywords like "appointment," "payment," "profile," "schedule," or "feedback" to get quick answers. What would you like to know?',
        isUser: false,
      ));
    });
  }

  // Get bot response
  Future<String> _getBotResponse(String userInput) async {
    String inputLower = userInput.toLowerCase().trim();
    final random = Random();

    // Check for greetings or general inquiry
    if (inputLower.contains('hi') ||
        inputLower.contains('hello') ||
        inputLower.contains('hey') ||
        inputLower.contains('can i ask')) {
      return '${_randomGreetings[random.nextInt(_randomGreetings.length)]} What’s on your mind today? Feel free to ask anything!';
    }

    // Check for exact match
    if (_qaDatabase.containsKey(userInput)) {
      return _qaDatabase[userInput]! +
          (_previousQuestions.contains(userInput)
              ? ' You asked this before—need more details?'
              : '');
    }

    // Search using string similarity
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
      return _qaDatabase[bestMatch]! +
          (_previousQuestions.contains(bestMatch)
              ? ' You asked this before—need more details?'
              : '');
    }

    // Search using synonyms
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
        return response +
            (_previousQuestions.contains(response)
                ? ' You checked this earlier—any other questions?'
                : '');
      }
    }

    // Check if the input is completely out of context
    bool isOutOfContext = !inputLower.containsAny([
      ..._keywordSynonyms.values.expand((x) => x),
      ..._keywordSynonyms.keys,
      'hi', 'hello', 'hey', 'ask'
    ]);
    if (isOutOfContext) {
      return 'Sorry, this topic is not available in the context of mental health or clinic services. Please ask questions related to appointments, payments, your profile, or mental health.';
    }

    // No API fallback, return a default message
    return 'Sorry, I didn’t understand that. Please try asking about appointments, payments, your profile, or mental health.';
  }

  // Handle user input
  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _previousQuestions.add(text);
    });
    _controller.clear();

    // Show loading indicator (optional without API, but kept for consistency)
    setState(() {
      _messages.add(ChatMessage(text: 'Loading...', isUser: false));
    });

    String response = await _getBotResponse(text);
    List<String> suggestions = _getDynamicSuggestions(text);
    setState(() {
      _messages.removeLast(); // Remove loading indicator
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        suggestions: suggestions,
      ));
    });
  }

  // Get dynamic suggestions
  List<String> _getDynamicSuggestions(String userInput) {
    if (_previousQuestions.isEmpty) {
      return _qaDatabase.keys.take(3).toList();
    }
    final lastQuestion = _previousQuestions.last;
    return _suggestedQuestions[lastQuestion] ?? _qaDatabase.keys.take(3).toList();
  }

  // Show questions sheet
  void _showQuestionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  width: 40.0,
                  height: 5.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select a Question',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff457B9D),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _qaDatabase.keys.length,
                    itemBuilder: (context, index) {
                      String question = _qaDatabase.keys.elementAt(index);
                      return Card(
                        elevation: 3.0,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _handleSubmitted(question);
                          },
                          borderRadius: BorderRadius.circular(12.0),
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.question_answer,
                                  color: Color(0xff457B9D),
                                  size: 30.0,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  question,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clinic Chatbot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        centerTitle: true,
        backgroundColor: Color(0xff457B9D),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xff457B9D)),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xff457B9D)),
                  onPressed: () => _handleSubmitted(_controller.text),
                ),
                IconButton(
                  icon: Icon(Icons.list, color: Color(0xff457B9D)),
                  onPressed: () => _showQuestionsSheet(context),
                  tooltip: 'Show Questions',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final List<String>? suggestions;

  ChatMessage({required this.text, required this.isUser, this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isUser ? Color(0xff457B9D).withOpacity(0.8) : Color(0xffF0E5CF).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.0,
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (suggestions != null && !isUser) ...[
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: suggestions!.map((suggestion) {
                return OutlinedButton(
                  onPressed: () {
                    TextEditingController().text = suggestion;
                    (context as Element)
                        .findAncestorStateOfType<_ChatbotScreenState>()!
                        ._handleSubmitted(suggestion);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xff457B9D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(color: Color(0xff457B9D), fontSize: 14.0),
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

// Extension to check if any string contains any substring
extension ContainsAny on String {
  bool containsAny(Iterable<String> values) {
    return values.any(contains);
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'bloc/chatbot_bloc.dart';
// import 'bloc/chatbot_event.dart';
// import 'services/chatbot_service.dart';
// import 'ui/chatbot_screen.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: BlocProvider(
//         create: (context) => ChatbotBloc(ChatbotService())..add(ChatbotInitEvent()),
//         child:  ChatbotScreen(),
//       ),
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//         textTheme: const TextTheme(
//           bodyMedium: TextStyle(fontSize: 16.0),
//         ),
//         cardTheme: CardTheme(
//           elevation: 2.0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//         ),
//       ),
//     );
//   }
// }