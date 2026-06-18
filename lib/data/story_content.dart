import '../models/quiz_model.dart';

/// Simulates content served by the Peblo backend.
abstract final class StoryContent {
  static const storyText =
      'Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...';

  /// Quiz JSON as it would arrive from the API.
  static const quizJson = {
    'question': "What colour was Pip the Robot's lost gear?",
    'options': ['Red', 'Green', 'Blue', 'Yellow'],
    'answer': 'Blue',
  };

  static QuizModel get quiz => QuizModel.fromJson(quizJson);
}
