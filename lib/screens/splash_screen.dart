import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_branding.dart';
import '../core/theme/app_theme.dart';
import 'story_buddy_screen.dart';

const _logoAspect = 156 / 59;

/// Animated splash — gradient, floating bubbles, logo reveal, then home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _master;
  late final AnimationController _bubbles;
  late final AnimationController _sparkle;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();

    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _bubbles = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _sparkle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _logoFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.05, 0.45, curve: Curves.elasticOut),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.28, 0.48, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.28, 0.52, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.42, 0.62, curve: Curves.easeOut),
    );

    _loaderFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
    );

    _master.forward();
    _master.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _goHome();
      }
    });
  }

  Future<void> _goHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const StoryBuddyScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _master.dispose();
    _bubbles.dispose();
    _sparkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoHeight = math.min(MediaQuery.sizeOf(context).width * 0.22, 88.0);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_master, _bubbles, _sparkle]),
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7B5CFF),
                  PebloColors.purple,
                  PebloColors.purpleDark,
                  Color(0xFF3D28B8),
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _FloatingBubbles(progress: _bubbles.value),
                _SparkleField(progress: _sparkle.value),
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _SplashLogo(height: logoHeight),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: Text(
                            AppBranding.name,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: _taglineFade,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            AppBranding.tagline,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                      FadeTransition(
                        opacity: _loaderFade,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Warming up the magic...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Logo on splash — no background box; transparent on gradient.
class _SplashLogo extends StatelessWidget {
  const _SplashLogo({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * _logoAspect,
      height: height,
      child: Image.asset(
        AppAssets.logo,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          AppAssets.logoPng,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _FloatingBubbles extends StatelessWidget {
  const _FloatingBubbles({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bubbles = [
      (0.12, 0.18, 56.0, PebloColors.orange),
      (0.82, 0.12, 42.0, PebloColors.sky),
      (0.88, 0.42, 68.0, PebloColors.orangeLight),
      (0.08, 0.55, 38.0, Colors.white),
      (0.55, 0.78, 50.0, PebloColors.sky),
      (0.25, 0.82, 34.0, PebloColors.orange),
    ];

    return CustomPaint(
      painter: _BubbleMotionPainter(
        progress: progress,
        bubbles: bubbles,
        size: size,
      ),
    );
  }
}

class _BubbleMotionPainter extends CustomPainter {
  _BubbleMotionPainter({
    required this.progress,
    required this.bubbles,
    required this.size,
  });

  final double progress;
  final List<(double, double, double, Color)> bubbles;
  final Size size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    for (var i = 0; i < bubbles.length; i++) {
      final (x, y, radius, color) = bubbles[i];
      final drift = math.sin((progress + i * 0.17) * math.pi * 2) * 14;
      final offset = Offset(size.width * x + drift, size.height * y - drift * 0.6);
      canvas.drawCircle(
        offset,
        radius,
        Paint()..color = color.withValues(alpha: 0.14),
      );
      canvas.drawCircle(
        offset,
        radius * 0.55,
        Paint()..color = Colors.white.withValues(alpha: 0.06),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubbleMotionPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SparkleField extends StatelessWidget {
  const _SparkleField({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const seeds = [
      (0.2, 0.3),
      (0.7, 0.25),
      (0.45, 0.15),
      (0.9, 0.6),
      (0.15, 0.7),
      (0.6, 0.85),
    ];

    return Stack(
      children: [
        for (var i = 0; i < seeds.length; i++)
          Positioned(
            left: size.width * seeds[i].$1,
            top: size.height * seeds[i].$2,
            child: Opacity(
              opacity: 0.25 + (math.sin(progress * math.pi * 2 + i) + 1) * 0.35,
              child: Icon(
                Icons.auto_awesome,
                size: 14 + (i % 3) * 4,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
      ],
    );
  }
}
