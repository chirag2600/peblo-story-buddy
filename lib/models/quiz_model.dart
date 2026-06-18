/// Data model for backend-driven quiz payloads.
class QuizModel {
  const QuizModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      answer: json['answer'] as String,
    );
  }

  final String question;
  final List<String> options;
  final String answer;

  bool isCorrect(String selected) => selected == answer;
}
