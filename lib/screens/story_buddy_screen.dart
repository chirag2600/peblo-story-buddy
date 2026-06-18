import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../data/story_content.dart';
import '../providers/story_buddy_provider.dart';
import '../widgets/ai_buddy_widget.dart';
import '../widgets/quiz_widget.dart';
import '../widgets/shake_wrapper.dart';
import '../widgets/success_overlay.dart';

class StoryBuddyScreen extends ConsumerWidget {
  const StoryBuddyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storyBuddyProvider);
    final notifier = ref.read(storyBuddyProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _BackgroundDecor(),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Peblo Story Buddy',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: PebloColors.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your AI reading companion',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: PebloColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AiBuddyWidget(
                    isHappy: state.buddyHappy,
                    isSpeaking: state.isSpeaking,
                  ),
                  const SizedBox(height: 24),
                  _ReadStoryButton(
                    isLoading: state.isLoading,
                    isSpeaking: state.isSpeaking,
                    enabled: state.canReadStory,
                    onPressed: notifier.readStory,
                  ),
                  if (state.hasError && state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _ErrorBanner(
                      message: state.errorMessage!,
                      onRetry: notifier.retry,
                    ),
                  ],
                  const SizedBox(height: 20),
                  _StoryCard(text: StoryContent.storyText),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.15),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: state.showQuiz
                        ? ShakeWrapper(
                            key: const ValueKey('quiz'),
                            trigger: state.shakeTrigger,
                            child: _QuizCard(
                              state: state,
                              onOptionSelected: notifier.selectAnswer,
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey('no-quiz'),
                            height: 0,
                          ),
                  ),
                  if (state.quizPhase == QuizPhase.success) ...[
                    const SizedBox(height: 16),
                    SuccessOverlay(visible: true),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundDecor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _BubblePainter(),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bubbles = [
      (Offset(size.width * 0.1, size.height * 0.12), 40.0, PebloColors.sky),
      (Offset(size.width * 0.85, size.height * 0.08), 28.0, PebloColors.orange),
      (Offset(size.width * 0.92, size.height * 0.35), 50.0, PebloColors.purple),
      (Offset(size.width * 0.05, size.height * 0.55), 35.0, PebloColors.orangeLight),
    ];

    for (final (offset, radius, color) in bubbles) {
      canvas.drawCircle(
        offset,
        radius,
        Paint()..color = color.withValues(alpha: 0.12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReadStoryButton extends StatelessWidget {
  const _ReadStoryButton({
    required this.isLoading,
    required this.isSpeaking,
    required this.enabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isSpeaking;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = isLoading
        ? 'Getting ready...'
        : isSpeaking
            ? 'Reading...'
            : 'Read Me a Story';

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: PebloColors.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: PebloColors.orange.withValues(alpha: 0.5),
          elevation: 4,
          shadowColor: PebloColors.orange.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading || isSpeaking)
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.auto_stories_rounded, size: 22),
              ),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PebloColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PebloColors.sky.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: PebloColors.purple.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: PebloColors.purple, size: 20),
              const SizedBox(width: 6),
              Text(
                'Story Time',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: PebloColors.purple,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  fontSize: 17,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.state,
    required this.onOptionSelected,
  });

  final StoryBuddyState state;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PebloColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state.quizPhase == QuizPhase.success
              ? PebloColors.success.withValues(alpha: 0.5)
              : PebloColors.purple.withValues(alpha: 0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: PebloColors.purple.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: QuizWidget(
        quiz: state.quiz,
        shakeTrigger: state.shakeTrigger,
        isSuccess: state.quizPhase == QuizPhase.success,
        onOptionSelected: onOptionSelected,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PebloColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PebloColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sentiment_dissatisfied_rounded,
              color: PebloColors.error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PebloColors.textDark,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
