import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Animated mesh gradient background that slowly shifts
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(color: AppColors.surfaceDark),

        // Animated orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return CustomPaint(
              painter: _OrbPainter(t),
              size: Size.infinite,
            );
          },
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;

  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Orb 1 — purple
    _drawOrb(
      canvas,
      Offset(
        w * (0.2 + 0.15 * math.sin(t * 2 * math.pi)),
        h * (0.15 + 0.1 * math.cos(t * 2 * math.pi * 0.7)),
      ),
      w * 0.5,
      AppColors.accentPrimary.withValues(alpha: 0.12),
    );

    // Orb 2 — cyan
    _drawOrb(
      canvas,
      Offset(
        w * (0.8 + 0.12 * math.cos(t * 2 * math.pi * 1.3)),
        h * (0.4 + 0.15 * math.sin(t * 2 * math.pi * 0.9)),
      ),
      w * 0.45,
      AppColors.accentSecondary.withValues(alpha: 0.08),
    );

    // Orb 3 — gold
    _drawOrb(
      canvas,
      Offset(
        w * (0.5 + 0.2 * math.sin(t * 2 * math.pi * 0.5)),
        h * (0.75 + 0.1 * math.cos(t * 2 * math.pi * 1.1)),
      ),
      w * 0.4,
      AppColors.accentGold.withValues(alpha: 0.06),
    );
  }

  void _drawOrb(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}
