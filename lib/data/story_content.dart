import '../models/quiz_model.dart';
import '../models/story_model.dart';

/// Simulates content served by the Peblo backend.
abstract final class StoryContent {
  static const storyJson = {
    'title': 'Pip and the Whispering Woods',
    'subtitle': 'A tale of courage, friendship, and one shiny blue gear',
    'paragraphs': [
      'Once upon a time, in a bright little town at the edge of rolling green hills, '
          'lived a clever little robot named Pip. Pip was small and curious, with eyes '
          'that twinkled like monsoon stars and a heart full of questions. His favourite '
          'treasure was a shiny blue gear — the very first part he had ever built himself.',
      'One sunny morning, Pip packed his little bag and set off to explore the Whispering '
          'Woods. The trees there were tall and gentle, and when the wind blew through their '
          'leaves, it sounded like they were telling secrets. Pip hopped along the mossy '
          'path, humming a happy tune, not knowing that adventure was waiting just ahead.',
      'Suddenly, a gust of wind whooshed past! Pip\'s shiny blue gear slipped from his hand '
          'and tumbled into the tall grass. "Oh no!" cried Pip, peering into the shadows. '
          'The woods seemed enormous, and every rustle made him wonder — was that his gear, '
          'or just a busy squirrel darting home?',
      'Just then, a friendly firefly named Zara lit up beside him. "Don\'t worry, Pip," she '
          'glowed softly. "The woods whisper clues to those who listen carefully." Together '
          'they searched near the babbling stream, under the fern leaves, and around the old '
          'banyan tree whose roots curled like sleeping snakes.',
      'At last, beneath a cluster of wild blue flowers, something sparkled. Pip reached down '
          'and gasped with joy — there was his shiny blue gear, safe and bright as ever! '
          '"We found it!" he cheered, and Zara danced circles of golden light around him.',
      'Pip clipped the gear back into place and felt braver than ever. He waved goodbye to '
          'Zara and walked home through the Whispering Woods, listening to their soft '
          'whispers one more time. And from that day on, Pip always remembered: when '
          'something feels lost, a little courage and a good friend can light the way home.',
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
