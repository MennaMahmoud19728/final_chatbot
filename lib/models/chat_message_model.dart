class ChatMessageModel {
  final String text;
  final bool isUser;
  final List<String>? suggestions;

  ChatMessageModel({
    required this.text,
    required this.isUser,
    this.suggestions,
  });
}