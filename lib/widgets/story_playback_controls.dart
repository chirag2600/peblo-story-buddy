import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/tts_service.dart';

/// Story narration controls — read, pause, resume, and stop.
class StoryPlaybackControls extends StatelessWidget {
  const StoryPlaybackControls({
    super.key,
    required this.ttsStatus,
    required this.onRead,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final TtsStatus ttsStatus;
  final VoidCallback onRead;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  bool get _isPreparing => ttsStatus == TtsStatus.preparing;
  bool get _isSpeaking => ttsStatus == TtsStatus.speaking;
  bool get _isPaused => ttsStatus == TtsStatus.paused;
  bool get _isActive => _isPreparing || _isSpeaking || _isPaused;

  @override
  Widget build(BuildContext context) {
    if (_isActive) {
      return _PlaybackBar(
        isPreparing: _isPreparing,
        isSpeaking: _isSpeaking,
        isPaused: _isPaused,
        onPause: onPause,
        onResume: onResume,
        onStop: onStop,
      );
    }

    return _ReadButton(
      enabled: ttsStatus == TtsStatus.idle ||
          ttsStatus == TtsStatus.completed ||
          ttsStatus == TtsStatus.error,
      onPressed: onRead,
    );
  }
}

class _ReadButton extends StatelessWidget {
  const _ReadButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.auto_stories_rounded, size: 22),
        label: const Text('Read Me a Story'),
        style: ElevatedButton.styleFrom(
          backgroundColor: PebloColors.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: PebloColors.orange.withValues(alpha: 0.5),
          elevation: 4,
          shadowColor: PebloColors.orange.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _PlaybackBar extends StatelessWidget {
  const _PlaybackBar({
    required this.isPreparing,
    required this.isSpeaking,
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final bool isPreparing;
  final bool isSpeaking;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final statusLabel = isPreparing
        ? 'Getting ready...'
        : isPaused
            ? 'Paused'
            : 'Reading story...';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PebloColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PebloColors.orange.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: PebloColors.orange.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (isPreparing)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: PebloColors.orange,
                  ),
                )
              else
                Icon(
                  isPaused ? Icons.pause_circle_filled : Icons.volume_up_rounded,
                  color: PebloColors.orange,
                  size: 20,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: PebloColors.orange,
                        fontWeight: FontWeight.w800,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!isPreparing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: isPaused
                      ? _ControlButton(
                          label: 'Resume',
                          icon: Icons.play_arrow_rounded,
                          color: PebloColors.success,
                          onPressed: onResume,
                        )
                      : _ControlButton(
                          label: 'Pause',
                          icon: Icons.pause_rounded,
                          color: PebloColors.purple,
                          onPressed: onPause,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ControlButton(
                    label: 'Stop',
                    icon: Icons.stop_rounded,
                    color: PebloColors.error,
                    onPressed: onStop,
                    outlined: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 20),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 20),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
    );
  }
}
