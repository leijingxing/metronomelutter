import 'dart:math';

import 'package:flutter/material.dart';

class WaveformView extends StatelessWidget {
  final List<double> peaks;
  final double progress;
  final bool live;
  final Color color;
  final Color progressColor;
  final double height;

  const WaveformView({
    super.key,
    required this.peaks,
    this.progress = 0,
    this.live = false,
    required this.color,
    required this.progressColor,
    this.height = 88,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WaveformPainter(
          peaks: peaks,
          progress: progress,
          live: live,
          color: color,
          progressColor: progressColor,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> peaks;
  final double progress;
  final bool live;
  final Color color;
  final Color progressColor;

  const _WaveformPainter({
    required this.peaks,
    required this.progress,
    required this.live,
    required this.color,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final Paint playedPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    if (peaks.isEmpty) {
      final Paint line = Paint()
        ..color = color.withOpacity(0.35)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        line,
      );
      return;
    }
    final int count = peaks.length;
    final double widthPerBar = size.width / count;
    final double maxBarHeight = size.height * 0.46;
    final double playedX = size.width * progress.clamp(0.0, 1.0);
    for (int i = 0; i < count; i++) {
      final double x = (i * widthPerBar) + (widthPerBar * 0.5);
      final double bar = max(1.5, peaks[i].clamp(0.0, 1.0) * maxBarHeight);
      final Offset p1 = Offset(x, (size.height * 0.5) - bar);
      final Offset p2 = Offset(x, (size.height * 0.5) + bar);
      final Paint paint = !live && x <= playedX ? playedPaint : basePaint;
      canvas.drawLine(p1, p2, paint);
    }
    if (!live) {
      final Paint cursor = Paint()
        ..color = progressColor.withOpacity(0.75)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(playedX, 0),
        Offset(playedX, size.height),
        cursor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.peaks != peaks ||
        oldDelegate.progress != progress ||
        oldDelegate.live != live ||
        oldDelegate.color != color ||
        oldDelegate.progressColor != progressColor;
  }
}
