import '../models/quiz_model.dart';
import '../models/story_model.dart';

/// Simulates content served by the Peblo backend.
abstract final class StoryContent {
  static const storyJson = {
    'title': 'Pip and the Whispering Woods',
    'subtitle': 'A little robot, a lost gear, and a happy ending',
    'paragraphs': [
      'Once upon a time, a clever little robot named Pip lived near the Whispering Woods. '
          'His favourite treasure was a shiny blue gear — the very first part he had ever built.',
      'One windy morning, Pip went for a walk in the woods. Whoosh! The gear slipped from his '
          'hand and vanished in the tall grass. "Oh no!" said Pip. A friendly firefly named '
          'Zara lit up beside him and helped him search.',
      'Under a patch of blue flowers, something sparkled — Pip\'s shiny blue gear! He clipped '
          'it back on, waved to Zara, and walked home with a big smile.',
    ],
  };

  static StoryModel get story => StoryModel.fromJson(storyJson);

  /// Convenience getter for TTS narration.
  static String get storyText => story.narrationText;

  /// Quiz JSON as it would arrive from the API.
  static const quizJson = {
    'question': "What colour was Pip the Robot's lost gear?",
    'options': ['Red', 'Green', 'Blue', 'Yellow'],
    'answer': 'Blue',
  };

  static QuizModel get quiz => QuizModel.fromJson(quizJson);
}
