import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/story_model.dart';

/// Book-style story card with scrollable paragraphs and read-aloud state.
class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.story,
    this.isActive = false,
    this.isPaused = false,
  });

  final StoryModel story;
  final bool isActive;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReading = isActive && !isPaused;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: PebloColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive
              ? PebloColors.orange.withValues(alpha: 0.65)
              : PebloColors.sky.withValues(alpha: 0.45),
          width: isActive ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isActive ? PebloColors.orange : PebloColors.purple)
                .withValues(alpha: isActive ? 0.14 : 0.08),
            blurRadius: isActive ? 22 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StoryCoverHeader(
            story: story,
            isActive: isActive,
            isPaused: isPaused,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MetaChip(
                  icon: Icons.schedule_rounded,
                  label: '${story.estimatedReadMinutes} min',
                ),
                _MetaChip(
                  icon: Icons.article_outlined,
                  label: '${story.paragraphs.length} parts',
                ),
                if (isActive)
                  _MetaChip(
                    icon: isPaused
                        ? Icons.pause_circle_outline
                        : Icons.graphic_eq_rounded,
                    label: isPaused ? 'Paused' : 'Reading',
                    accent: true,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.38,
              ),
              decoration: BoxDecoration(
                color: PebloColors.cream.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: PebloColors.purple.withValues(alpha: 0.08),
                ),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                radius: const Radius.circular(8),
                child: ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: story.paragraphs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _StoryParagraph(
                      index: index + 1,
                      text: story.paragraphs[index],
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Text(
              isReading
                  ? 'Listen along — use Pause or Stop above anytime.'
                  : 'Tap "Read Me a Story" and listen along!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: PebloColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCoverHeader extends StatelessWidget {
  const _StoryCoverHeader({
    required this.story,
    required this.isActive,
    required this.isPaused,
  });

  final StoryModel story;
  final bool isActive;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [PebloColors.orange, PebloColors.orangeLight]
              : [PebloColors.purple, PebloColors.purpleDark],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Story Time',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.forest_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            story.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            story.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryParagraph extends StatelessWidget {
  const _StoryParagraph({
    required this.index,
    required this.text,
  });

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: PebloColors.purple.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: theme.textTheme.labelSmall?.copyWith(
              color: PebloColors.purple,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.65,
              fontSize: 16.5,
              color: PebloColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final fg = accent ? PebloColors.orange : PebloColors.purple;
    final bg = accent
        ? PebloColors.orange.withValues(alpha: 0.12)
        : PebloColors.skyLight.withValues(alpha: 0.55);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: accent
            ? Border.all(color: PebloColors.orange.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
