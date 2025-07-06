import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chatbot_bloc.dart';
import '../bloc/chatbot_event.dart';
import '../bloc/chatbot_state.dart';
import '../models/chat_message_model.dart';
import 'widgets/chat_message_widget.dart';

class ChatbotScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

   ChatbotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clinic Chatbot',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff457B9D),
      ),
      body: BlocListener<ChatbotBloc, ChatbotState>(
        listener: (context, state) {
          if (state is ChatbotShowQuestions) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
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
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          width: 40.0,
                          height: 5.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        const Padding(
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
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: state.questions.length,
                            itemBuilder: (context, index) {
                              String question = state.questions[index];
                              return Card(
                                elevation: 3.0,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.read<ChatbotBloc>().add(SendMessageEvent(question));
                                  },
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.question_answer,
                                          color: Color(0xff457B9D),
                                          size: 30.0,
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          question,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
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
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatbotBloc, ChatbotState>(
                builder: (context, state) {
                  if (state is ChatbotInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatbotLoaded) {
                    return ListView.builder(
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) => ChatMessageWidget(
                        message: state.messages[index],
                        onSuggestionTap: (suggestion) {
                          context.read<ChatbotBloc>().add(SendMessageEvent(suggestion));
                        },
                      ),
                    );
                  } else if (state is ChatbotError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
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
                          borderSide: const BorderSide(color: Color(0xff457B9D)),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          context.read<ChatbotBloc>().add(SendMessageEvent(text));
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xff457B9D)),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        context.read<ChatbotBloc>().add(SendMessageEvent(_controller.text));
                        _controller.clear();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.list, color: Color(0xff457B9D)),
                    onPressed: () => context.read<ChatbotBloc>().add(ShowQuestionsEvent()),
                    tooltip: 'Show Questions',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}