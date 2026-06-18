import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/story_content.dart';
import '../models/quiz_model.dart';
import '../services/tts_service.dart';

enum QuizPhase { hidden, revealing, visible, success }

class StoryBuddyState {
  const StoryBuddyState({
    this.ttsStatus = TtsStatus.idle,
    this.quizPhase = QuizPhase.hidden,
    required this.quiz,
    this.shakeTrigger = 0,
    this.buddyHappy = false,
    this.errorMessage,
  });

  factory StoryBuddyState.initial() => StoryBuddyState(quiz: StoryContent.quiz);

  final TtsStatus ttsStatus;
  final QuizPhase quizPhase;
  final QuizModel quiz;
  final int shakeTrigger;
  final bool buddyHappy;
  final String? errorMessage;

  bool get isLoading => ttsStatus == TtsStatus.preparing;
  bool get isSpeaking => ttsStatus == TtsStatus.speaking;
  bool get isPaused => ttsStatus == TtsStatus.paused;
  bool get isNarrating => isSpeaking || isPaused || isLoading;
  bool get hasError => ttsStatus == TtsStatus.error;
  bool get canReadStory =>
      ttsStatus == TtsStatus.idle ||
      ttsStatus == TtsStatus.completed ||
      ttsStatus == TtsStatus.error;
  bool get showQuiz =>
      quizPhase == QuizPhase.visible || quizPhase == QuizPhase.success;

  StoryBuddyState copyWith({
    TtsStatus? ttsStatus,
    QuizPhase? quizPhase,
    QuizModel? quiz,
    int? shakeTrigger,
    bool? buddyHappy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StoryBuddyState(
      ttsStatus: ttsStatus ?? this.ttsStatus,
      quizPhase: quizPhase ?? this.quizPhase,
      quiz: quiz ?? this.quiz,
      shakeTrigger: shakeTrigger ?? this.shakeTrigger,
      buddyHappy: buddyHappy ?? this.buddyHappy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class StoryBuddyNotifier extends StateNotifier<StoryBuddyState> {
  StoryBuddyNotifier(this._tts) : super(StoryBuddyState.initial()) {
    _subscription = _tts.statusStream.listen(_onTtsStatusChanged);
  }

  final TtsService _tts;
  late final StreamSubscription<TtsStatus> _subscription;

  void _onTtsStatusChanged(TtsStatus status) {
    switch (status) {
      case TtsStatus.completed:
        state = state.copyWith(
          ttsStatus: status,
          quizPhase: QuizPhase.revealing,
          clearError: true,
        );
        Future.delayed(const Duration(milliseconds: 400), () {
          if (state.ttsStatus == TtsStatus.completed) {
            state = state.copyWith(quizPhase: QuizPhase.visible);
          }
        });
      case TtsStatus.error:
        state = state.copyWith(
          ttsStatus: status,
          errorMessage:
              "Oops! I couldn't read the story. Tap the button to try again!",
        );
      default:
        state = state.copyWith(ttsStatus: status, clearError: true);
    }
  }

  Future<void> readStory() async {
    if (!state.canReadStory) return;

    state = state.copyWith(
      quizPhase: QuizPhase.hidden,
      buddyHappy: false,
      clearError: true,
    );

    await _tts.speak(StoryContent.storyText);
  }

  Future<void> pauseStory() => _tts.pause();

  Future<void> resumeStory() => _tts.resume();

  Future<void> stopStory() async {
    state = state.copyWith(
      quizPhase: QuizPhase.hidden,
      buddyHappy: false,
    );
    await _tts.stop();
  }

  void retry() => readStory();

  void selectAnswer(String option) {
    if (state.quizPhase != QuizPhase.visible) return;

    if (state.quiz.isCorrect(option)) {
      state = state.copyWith(
        quizPhase: QuizPhase.success,
        buddyHappy: true,
      );
    } else {
      state = state.copyWith(shakeTrigger: state.shakeTrigger + 1);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

final storyBuddyProvider =
    StateNotifierProvider<StoryBuddyNotifier, StoryBuddyState>((ref) {
  return StoryBuddyNotifier(ref.watch(ttsServiceProvider));
});
