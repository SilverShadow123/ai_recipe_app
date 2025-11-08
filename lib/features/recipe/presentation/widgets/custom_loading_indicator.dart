import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatefulWidget {
  const CustomLoadingIndicator({super.key});

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Controls the rotation animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Infinite rotation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi, // full rotation
            child: CustomPaint(
              painter: _DualColorArcPainter(),
            ),
          );
        },
      ),
    );
  }
}

class _DualColorArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 4.0;
    final radius = size.width / 2 - strokeWidth / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background circle (light gray)
    paint.color = Colors.grey.withAlpha(50);
    canvas.drawCircle(size.center(Offset.zero), radius, paint);

    // Orange arc
    final orangeStart = -math.pi / 6; // starting angle
    final orangeSweep = math.pi / 2;  // sweep angle
    paint.color = Colors.orange;
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      orangeStart,
      orangeSweep,
      false,
      paint,
    );

    // Green arc right after orange
    final greenStart = orangeStart + orangeSweep; // start after orange
    final greenSweep = math.pi / 2; // same length or adjust
    paint.color = Colors.green;
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      greenStart,
      greenSweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

