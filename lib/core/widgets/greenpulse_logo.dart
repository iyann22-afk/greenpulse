import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:greenpulse/app/app_colors.dart';

/// Custom GREENPULSE logo — leaf + signal wave concept
class GreenPulseLogo extends StatefulWidget {
  final double size;
  final bool animate;

  const GreenPulseLogo({super.key, this.size = 40, this.animate = false});

  @override
  State<GreenPulseLogo> createState() => _GreenPulseLogoState();
}

class _GreenPulseLogoState extends State<GreenPulseLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulse = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _ctrl.repeat(reverse: true);
    }
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
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _LogoPainter(pulse: widget.animate ? _pulse.value : 1.0),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double pulse;
  _LogoPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background circle
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.forestGreen, AppColors.pulseGreen],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(Offset(w / 2, h / 2), w / 2, bgPaint);

    // Leaf shape
    final leafPaint = Paint()
      ..color = AppColors.freshLime
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    final cx = w * 0.42;
    final cy = h * 0.55;
    final lw = w * 0.32;
    final lh = h * 0.38;

    leafPath.moveTo(cx, cy - lh);
    leafPath.cubicTo(
      cx + lw, cy - lh * 0.5,
      cx + lw, cy + lh * 0.3,
      cx, cy + lh * 0.3,
    );
    leafPath.cubicTo(
      cx - lw * 0.5, cy + lh * 0.3,
      cx - lw * 0.5, cy - lh * 0.3,
      cx, cy - lh,
    );
    leafPath.close();

    canvas.save();
    canvas.rotate(-math.pi / 6);
    canvas.translate(-h * 0.08, h * 0.12);
    canvas.drawPath(leafPath, leafPaint);

    // Leaf vein
    final veinPaint = Paint()
      ..color = AppColors.forestGreen.withOpacity(0.5)
      ..strokeWidth = w * 0.03
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final veinPath = Path();
    veinPath.moveTo(cx, cy - lh);
    veinPath.cubicTo(cx - lw * 0.1, cy - lh * 0.2, cx - lw * 0.1, cy + lh * 0.1, cx, cy + lh * 0.3);
    canvas.drawPath(veinPath, veinPaint);
    canvas.restore();

    // Signal wave (pulse lines on the right side)
    final wavePaint = Paint()
      ..color = AppColors.pureWhite.withOpacity(0.9 * pulse)
      ..strokeWidth = w * 0.055
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx2 = w * 0.65;
    final cy2 = h * 0.42;
    final r1 = w * 0.10;
    final r2 = w * 0.17;

    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx2, cy2), width: r1 * 2, height: r1 * 2),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      wavePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx2, cy2), width: r2 * 2, height: r2 * 2),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      wavePaint..color = AppColors.pureWhite.withOpacity(0.55 * pulse),
    );

    // Center dot for signal
    canvas.drawCircle(
      Offset(cx2, cy2),
      w * 0.045,
      Paint()..color = AppColors.pureWhite,
    );
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.pulse != pulse;
}
