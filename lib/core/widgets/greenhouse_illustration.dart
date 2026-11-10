import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:greenpulse/app/app_colors.dart';

/// Animated botanical greenhouse hero illustration with living plants,
/// falling moisture droplets, shifting god-rays, and floating bio-particles.
class GreenhouseHeroIllustration extends StatefulWidget {
  const GreenhouseHeroIllustration({super.key});

  @override
  State<GreenhouseHeroIllustration> createState() =>
      _GreenhouseHeroIllustrationState();
}

class _GreenhouseHeroIllustrationState
    extends State<GreenhouseHeroIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _AnimatedGreenhousePainter(progress: _ctrl.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _AnimatedGreenhousePainter extends CustomPainter {
  final double progress;

  _AnimatedGreenhousePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = progress * 2 * math.pi;

    // 1. Sky & atmosphere background
    _drawBackground(canvas, w, h, t);

    // 2. Light rays (behind plants)
    _drawShiftingLightRays(canvas, w, h, t);

    // 3. Greenhouse glass panels
    _drawGlassPanels(canvas, w, h, t);

    // 4. Ground / soil / nutrient bed
    _drawGround(canvas, w, h, t);

    // 5. Living animated plants
    _drawAnimatedPlants(canvas, w, h, t);

    // 6. Falling moisture droplets & ripples
    _drawAnimatedDroplets(canvas, w, h, t);

    // 7. Floating bio-particles / spores / mist
    _drawFloatingParticles(canvas, w, h, t);
  }

  void _drawBackground(Canvas canvas, double w, double h, double t) {
    // Subtle pulsating atmosphere
    final pulse = math.sin(t) * 0.05;
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0D2B1A),
          const Color(0xFF143D2B),
          Color.lerp(const Color(0xFF1A5235), const Color(0xFF236542),
              0.5 + pulse)!,
          const Color(0xFF27AE60),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);
  }

  void _drawGlassPanels(Canvas canvas, double w, double h, double t) {
    // Glass structure with subtle reflective sheen
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Horizontal panels
    for (int i = 1; i <= 5; i++) {
      final y = h * i / 5;
      canvas.drawLine(Offset(0, y), Offset(w, y), linePaint);
    }
    // Vertical panels
    for (int i = 1; i <= 6; i++) {
      final x = w * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, h), linePaint);
    }

    // Moving diagonal glass glare
    final glareX = (progress * 1.4 - 0.2) * w;
    final glarePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.04),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(glareX, 0, 70, h));

    final glarePath = Path()
      ..moveTo(glareX, 0)
      ..lineTo(glareX + 50, 0)
      ..lineTo(glareX - 20, h)
      ..lineTo(glareX - 70, h)
      ..close();
    canvas.drawPath(glarePath, glarePaint);
  }

  void _drawShiftingLightRays(Canvas canvas, double w, double h, double t) {
    for (int i = 0; i < 4; i++) {
      final rayT = t + i * 1.3;
      final shift = math.sin(rayT) * 14.0;
      final rayOpacity = (0.06 + math.sin(rayT * 1.5) * 0.035).clamp(0.02, 0.12);

      final rayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.freshLime.withOpacity(rayOpacity * 1.5),
            AppColors.freshLime.withOpacity(rayOpacity * 0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h));

      final startX = w * (0.12 + i * 0.26) + shift * 0.3;
      final endX = w * (0.12 + i * 0.26) + shift;

      final path = Path()
        ..moveTo(startX - 18, 0)
        ..lineTo(startX + 18, 0)
        ..lineTo(endX + 60, h)
        ..lineTo(endX - 60, h)
        ..close();

      canvas.drawPath(path, rayPaint);
    }
  }

  void _drawGround(Canvas canvas, double w, double h, double t) {
    final wave = math.sin(t * 0.8) * 2.0;

    final ground = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2D5A27).withOpacity(0.85),
          const Color(0xFF142E11),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.70, w, h * 0.30));

    final path = Path()
      ..moveTo(0, h * 0.75 + wave)
      ..cubicTo(
        w * 0.25,
        h * 0.70 - wave,
        w * 0.75,
        h * 0.78 + wave,
        w,
        h * 0.72 - wave,
      )
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(path, ground);

    // Soil highlight rim
    final rimPaint = Paint()
      ..color = AppColors.pulseGreen.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rimPath = Path()
      ..moveTo(0, h * 0.75 + wave)
      ..cubicTo(
        w * 0.25,
        h * 0.70 - wave,
        w * 0.75,
        h * 0.78 + wave,
        w,
        h * 0.72 - wave,
      );

    canvas.drawPath(rimPath, rimPaint);
  }

  void _drawAnimatedPlants(Canvas canvas, double w, double h, double t) {
    // Plant 1 - Left large plant
    final sway1 = math.sin(t) * 0.09;
    _drawLargePlant(canvas, w * 0.15, h * 0.75, h * 0.45, AppColors.freshLime,
        sway: sway1, breathPhase: t);

    // Plant 2 - Center large plant
    final sway2 = math.sin(t + 1.4) * 0.08;
    _drawLargePlant(canvas, w * 0.50, h * 0.78, h * 0.52, const Color(0xFF5DBB3F),
        sway: sway2, breathPhase: t + 1.0);

    // Plant 3 - Right large plant
    final sway3 = math.sin(t + 2.7) * 0.10;
    _drawLargePlant(canvas, w * 0.82, h * 0.73, h * 0.40, const Color(0xFF8BCF4A),
        sway: sway3, breathPhase: t + 2.0);

    // Plant 4 - Small plant between 1 & 2
    final sway4 = math.sin(t + 0.8) * 0.12;
    _drawSmallPlant(canvas, w * 0.30, h * 0.80, h * 0.25, const Color(0xFF4CAF50),
        sway: sway4, breathPhase: t + 0.5);

    // Plant 5 - Small plant between 2 & 3
    final sway5 = math.sin(t + 3.2) * 0.11;
    _drawSmallPlant(canvas, w * 0.68, h * 0.82, h * 0.22, AppColors.freshLime,
        sway: sway5, breathPhase: t + 1.8);
  }

  void _drawLargePlant(
    Canvas canvas,
    double x,
    double y,
    double size,
    Color color, {
    required double sway,
    required double breathPhase,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(sway);

    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = size * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Curved living stem
    final stemPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(
        sway * size * 0.3,
        -size * 0.25,
        -sway * size * 0.2,
        -size * 0.4,
        0,
        -size * 0.5,
      );
    canvas.drawPath(stemPath, stemPaint);

    // Leaves with harmonic breathing & micro-sway
    final leafPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final leafSway1 = math.sin(breathPhase * 1.3) * 0.06;
    final leafSway2 = math.sin(breathPhase * 1.3 + 1.5) * 0.06;
    final leafSway3 = math.sin(breathPhase * 1.3 + 3.0) * 0.05;

    _drawLeaf(canvas, leafPaint, 0, -size * 0.28, size * 0.32,
        -math.pi / 4 + leafSway1);
    _drawLeaf(canvas, leafPaint, 0, -size * 0.38, size * 0.30,
        math.pi / 4 + leafSway2);
    _drawLeaf(
        canvas, leafPaint, 0, -size * 0.50, size * 0.34, 0.0 + leafSway3);

    canvas.restore();
  }

  void _drawSmallPlant(
    Canvas canvas,
    double x,
    double y,
    double size,
    Color color, {
    required double sway,
    required double breathPhase,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(sway);

    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = size * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset.zero, Offset(0, -size * 0.4), stemPaint);

    final leafPaint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final leafSway = math.sin(breathPhase) * 0.07;

    _drawLeaf(canvas, leafPaint, 0, -size * 0.15, size * 0.26,
        -math.pi / 6 + leafSway);
    _drawLeaf(canvas, leafPaint, 0, -size * 0.25, size * 0.23,
        math.pi / 6 - leafSway);
    _drawLeaf(canvas, leafPaint, 0, -size * 0.38, size * 0.22,
        math.pi / 2.5 + leafSway);

    canvas.restore();
  }

  void _drawLeaf(
      Canvas canvas, Paint paint, double x, double y, double size, double angle) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(size * 0.4, -size * 0.5, size * 0.8, -size * 0.4, size, 0)
      ..cubicTo(size * 0.8, size * 0.3, size * 0.4, size * 0.2, 0, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Leaf vein
    final veinPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = size * 0.03
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size * 0.75, 0), veinPaint);

    canvas.restore();
  }

  void _drawAnimatedDroplets(Canvas canvas, double w, double h, double t) {
    // 7 continuous moisture raindrops falling through the air
    final dropConfigs = [
      (xRatio: 0.18, speed: 1.0, phase: 0.1, radius: 3.5),
      (xRatio: 0.26, speed: 1.3, phase: 0.6, radius: 2.5),
      (xRatio: 0.46, speed: 0.9, phase: 0.3, radius: 4.0),
      (xRatio: 0.62, speed: 1.2, phase: 0.8, radius: 3.0),
      (xRatio: 0.72, speed: 1.1, phase: 0.15, radius: 3.8),
      (xRatio: 0.85, speed: 1.4, phase: 0.5, radius: 2.8),
      (xRatio: 0.92, speed: 0.95, phase: 0.9, radius: 3.2),
    ];

    for (final d in dropConfigs) {
      final yProgress = (progress * d.speed + d.phase) % 1.0;
      final startY = h * 0.08;
      final endY = h * 0.76;
      final currentY = startY + yProgress * (endY - startY);
      final currentX = w * d.xRatio + math.sin(t + d.phase * 5) * 4.0;

      // Fade in near top, fade out near ground
      double opacity = 0.5;
      if (yProgress < 0.15) {
        opacity = (yProgress / 0.15) * 0.5;
      } else if (yProgress > 0.85) {
        opacity = ((1.0 - yProgress) / 0.15) * 0.5;
      }

      final dropPaint = Paint()
        ..color = const Color(0xFF64B5F6).withOpacity(opacity.clamp(0.0, 0.7))
        ..style = PaintingStyle.fill;

      _drawTearDrop(canvas, dropPaint, Offset(currentX, currentY), d.radius);

      // Splash ripple when near bottom
      if (yProgress > 0.80) {
        final rippleProgress = (yProgress - 0.80) / 0.20;
        final ripplePaint = Paint()
          ..color = const Color(0xFF90CAF9)
              .withOpacity((1.0 - rippleProgress) * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(currentX, endY),
            width: rippleProgress * 18,
            height: rippleProgress * 6,
          ),
          ripplePaint,
        );
      }
    }
  }

  void _drawTearDrop(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path()
      ..moveTo(center.dx, center.dy - r * 2.0)
      ..cubicTo(
        center.dx + r * 1.3,
        center.dy - r * 0.6,
        center.dx + r * 1.1,
        center.dy + r * 0.9,
        center.dx,
        center.dy + r * 1.1,
      )
      ..cubicTo(
        center.dx - r * 1.1,
        center.dy + r * 0.9,
        center.dx - r * 1.3,
        center.dy - r * 0.6,
        center.dx,
        center.dy - r * 2.0,
      )
      ..close();

    canvas.drawPath(path, paint);

    // Droplet highlight reflection
    final highlight = Paint()..color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(
      Offset(center.dx - r * 0.3, center.dy - r * 0.4),
      r * 0.35,
      highlight,
    );
  }

  void _drawFloatingParticles(Canvas canvas, double w, double h, double t) {
    // 8 floating bio-particles / spores drifting gently upward
    for (int i = 0; i < 8; i++) {
      final floatProgress = (progress * 0.6 + i * 0.125) % 1.0;
      final py = h * (0.80 - floatProgress * 0.70);
      final px = w * (0.08 + i * 0.12) + math.sin(t * 1.4 + i * 2) * 12.0;
      final pRadius = 1.5 + (i % 3) * 0.8;

      final pOpacity =
          (math.sin(floatProgress * math.pi) * 0.55).clamp(0.0, 0.6);

      // Outer glow
      final glowPaint = Paint()
        ..color = AppColors.freshLime.withOpacity(pOpacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(px, py), pRadius * 1.8, glowPaint);

      // Core particle
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(pOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, py), pRadius, corePaint);
    }
  }

  @override
  bool shouldRepaint(_AnimatedGreenhousePainter old) =>
      old.progress != progress;
}
