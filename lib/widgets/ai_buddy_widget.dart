import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Custom-painted StorySpark buddy — lightweight, no image assets.
class AiBuddyWidget extends StatelessWidget {
  const AiBuddyWidget({
    super.key,
    required this.isHappy,
    this.isSpeaking = false,
  });

  final bool isHappy;
  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 130,
      child: CustomPaint(
        painter: _BuddyPainter(isHappy: isHappy, isSpeaking: isSpeaking),
      ),
    );
  }
}

class _BuddyPainter extends CustomPainter {
  _BuddyPainter({required this.isHappy, required this.isSpeaking});

  final bool isHappy;
  final bool isSpeaking;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    final radius = size.width * 0.38;

    final glowPaint = Paint()
      ..color = PebloColors.purple.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius + 8, glowPaint);

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [PebloColors.purple, PebloColors.purpleDark],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bodyPaint);

    final antennaPaint = Paint()
      ..color = PebloColors.orange
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final antennaTop = Offset(center.dx, center.dy - radius - 14);
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 4),
      antennaTop,
      antennaPaint,
    );
    canvas.drawCircle(antennaTop, 5, Paint()..color = PebloColors.orangeLight);

    final eyeY = center.dy - radius * 0.15;
    final eyeOffset = radius * 0.28;

    if (isHappy) {
      final smilePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      for (final dx in [center.dx - eyeOffset, center.dx + eyeOffset]) {
        final eye = Path()
          ..addArc(
            Rect.fromCenter(center: Offset(dx, eyeY), width: 14, height: 8),
            0,
            3.14,
          );
        canvas.drawPath(eye, smilePaint);
      }

      final smile = Path()
        ..addArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + radius * 0.2),
            width: radius * 0.6,
            height: radius * 0.35,
          ),
          0.2,
          2.8,
        );
      canvas.drawPath(smile, smilePaint);
    } else {
      final eyePaint = Paint()..color = Colors.white;
      final pupilPaint = Paint()..color = PebloColors.textDark;
      canvas.drawCircle(Offset(center.dx - eyeOffset, eyeY), 8, eyePaint);
      canvas.drawCircle(Offset(center.dx + eyeOffset, eyeY), 8, eyePaint);
      canvas.drawCircle(Offset(center.dx - eyeOffset, eyeY), 4, pupilPaint);
      canvas.drawCircle(Offset(center.dx + eyeOffset, eyeY), 4, pupilPaint);

      if (isSpeaking) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + radius * 0.25),
            width: 12,
            height: 16,
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );
      } else {
        canvas.drawCircle(
          Offset(center.dx, center.dy + radius * 0.25),
          4,
          Paint()..color = Colors.white.withValues(alpha: 0.8),
        );
      }
    }

    final blush = Paint()..color = PebloColors.orange.withValues(alpha: 0.35);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.55, center.dy + radius * 0.1),
      6,
      blush,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.55, center.dy + radius * 0.1),
      6,
      blush,
    );
  }

  @override
  bool shouldRepaint(covariant _BuddyPainter oldDelegate) =>
      oldDelegate.isHappy != isHappy || oldDelegate.isSpeaking != isSpeaking;
}
