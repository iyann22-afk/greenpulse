import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:greenpulse/app/app_colors.dart';

/// Botanical greenhouse hero illustration drawn with Flutter canvas
class GreenhouseHeroIllustration extends StatelessWidget {
  const GreenhouseHeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GreenhousePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _GreenhousePainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient background
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0D2B1A),
          Color(0xFF143D2B),
          Color(0xFF1A5235),
          Color(0xFF27AE60),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Grid lines (greenhouse glass panels)
    _drawGlassPanels(canvas, w, h);

    // Ground / soil
    _drawGround(canvas, w, h);

    // Plants / leaves
    _drawPlants(canvas, w, h);

    // Light rays
    _drawLightRays(canvas, w, h);

    // Moisture droplets
    _drawDroplets(canvas, w, h);
  }

  void _drawGlassPanels(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    for (int i = 1; i <= 5; i++) {
      final y = h * i / 5;
      canvas.drawLine(Offset(0, y), Offset(w, y), paint);
    }
    // Vertical lines
    for (int i = 1; i <= 6; i++) {
      final x = w * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, h), paint);
    }
  }

  void _drawGround(Canvas canvas, double w, double h) {
    final ground = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2D5A27).withOpacity(0.8),
          const Color(0xFF1A3A15),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.72, w, h * 0.28));
    final path = Path()
      ..moveTo(0, h * 0.75)
      ..cubicTo(w * 0.25, h * 0.70, w * 0.75, h * 0.78, w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, ground);
  }

  void _drawPlants(Canvas canvas, double w, double h) {
    _drawLargePlant(canvas, w * 0.15, h * 0.75, h * 0.45, AppColors.freshLime);
    _drawLargePlant(canvas, w * 0.5, h * 0.78, h * 0.52, const Color(0xFF5DBB3F));
    _drawLargePlant(canvas, w * 0.82, h * 0.73, h * 0.40, const Color(0xFF8BCF4A));
    _drawSmallPlant(canvas, w * 0.3, h * 0.80, h * 0.25, const Color(0xFF4CAF50));
    _drawSmallPlant(canvas, w * 0.68, h * 0.82, h * 0.22, AppColors.freshLime);
  }

  void _drawLargePlant(Canvas canvas, double x, double y, double size, Color color) {
    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = size * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Stem
    canvas.drawLine(Offset(x, y), Offset(x, y - size * 0.5), stemPaint);

    // Leaves
    final leafPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    _drawLeaf(canvas, leafPaint, x, y - size * 0.3, size * 0.3, -math.pi / 4);
    _drawLeaf(canvas, leafPaint, x, y - size * 0.4, size * 0.28, math.pi / 4);
    _drawLeaf(canvas, leafPaint, x, y - size * 0.5, size * 0.32, 0);
  }

  void _drawSmallPlant(Canvas canvas, double x, double y, double size, Color color) {
    final leafPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    _drawLeaf(canvas, leafPaint, x, y, size * 0.25, -math.pi / 6);
    _drawLeaf(canvas, leafPaint, x, y, size * 0.22, math.pi / 6);
    _drawLeaf(canvas, leafPaint, x, y, size * 0.20, math.pi / 2.5);
  }

  void _drawLeaf(Canvas canvas, Paint paint, double x, double y, double size, double angle) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(size * 0.4, -size * 0.5, size * 0.8, -size * 0.4, size, 0)
      ..cubicTo(size * 0.8, size * 0.3, size * 0.4, size * 0.2, 0, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawLightRays(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = AppColors.freshLime.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final startX = w * (0.1 + i * 0.26);
      final path = Path()
        ..moveTo(startX - 15, 0)
        ..lineTo(startX + 15, 0)
        ..lineTo(startX + 50, h)
        ..lineTo(startX - 50, h)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawDroplets(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final positions = [
      Offset(w * 0.2, h * 0.3),
      Offset(w * 0.45, h * 0.2),
      Offset(w * 0.7, h * 0.35),
      Offset(w * 0.88, h * 0.25),
      Offset(w * 0.1, h * 0.55),
    ];

    for (final pos in positions) {
      _drawDroplet(canvas, paint, pos, 4);
    }
  }

  void _drawDroplet(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path()
      ..moveTo(center.dx, center.dy - r * 1.8)
      ..cubicTo(
        center.dx + r * 1.2, center.dy - r * 0.6,
        center.dx + r, center.dy + r * 0.8,
        center.dx, center.dy + r,
      )
      ..cubicTo(
        center.dx - r, center.dy + r * 0.8,
        center.dx - r * 1.2, center.dy - r * 0.6,
        center.dx, center.dy - r * 1.8,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GreenhousePainter old) => false;
}
