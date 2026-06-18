import 'package:flutter_test/flutter_test.dart';
import 'package:peblo_story_buddy/data/story_content.dart';
import 'package:peblo_story_buddy/models/quiz_model.dart';

void main() {
  group('QuizModel', () {
    test('parses JSON with variable option counts', () {
      final threeOptions = QuizModel.fromJson({
        'question': 'Pick one',
        'options': ['A', 'B', 'C'],
        'answer': 'B',
      });
      expect(threeOptions.options.length, 3);

      final fiveOptions = QuizModel.fromJson({
        'question': 'Pick one',
        'options': ['A', 'B', 'C', 'D', 'E'],
        'answer': 'E',
      });
      expect(fiveOptions.options.length, 5);
    });

    test('validates correct answer from challenge payload', () {
      final quiz = QuizModel.fromJson(StoryContent.quizJson);
      expect(quiz.isCorrect('Blue'), isTrue);
      expect(quiz.isCorrect('Red'), isFalse);
    });
  });
}
