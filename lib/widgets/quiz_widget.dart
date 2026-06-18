import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/quiz_model.dart';

/// Renders quiz questions and a variable number of options from [QuizModel].
class QuizWidget extends StatelessWidget {
  const QuizWidget({
    super.key,
    required this.quiz,
    required this.onOptionSelected,
    required this.shakeTrigger,
    this.isSuccess = false,
  });

  final QuizModel quiz;
  final ValueChanged<String> onOptionSelected;
  final int shakeTrigger;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Quiz!',
          style: theme.textTheme.titleMedium?.copyWith(
            color: PebloColors.purple,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          quiz.question,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ...List.generate(quiz.options.length, (index) {
          final option = quiz.options[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < quiz.options.length - 1 ? 10 : 0,
            ),
            child: _QuizOptionButton(
              label: option,
              color: _optionColor(index),
              enabled: !isSuccess,
              onTap: () => onOptionSelected(option),
            ),
          );
        }),
      ],
    );
  }

  Color _optionColor(int index) {
    const palette = [
      PebloColors.orange,
      PebloColors.sky,
      PebloColors.purple,
      PebloColors.orangeLight,
      Color(0xFFFF6B9D),
    ];
    return palette[index % palette.length];
  }
}

class _QuizOptionButton extends StatelessWidget {
  const _QuizOptionButton({
    required this.label,
    required this.color,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color : color.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      elevation: enabled ? 3 : 0,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
