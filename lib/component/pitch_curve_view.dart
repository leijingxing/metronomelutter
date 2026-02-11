import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PitchCurveView extends StatelessWidget {
  final List<double?> values;
  final double rangeCents;
  final double height;
  final Color lineColor;
  final Color targetColor;
  final Color gridColor;

  const PitchCurveView({
    super.key,
    required this.values,
    required this.lineColor,
    required this.targetColor,
    required this.gridColor,
    this.rangeCents = 50,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _PitchCurvePainter(
          values: values,
          rangeCents: rangeCents,
          lineColor: lineColor,
          targetColor: targetColor,
          gridColor: gridColor,
        ),
      ),
    );
  }
}

class _PitchCurvePainter extends CustomPainter {
  final List<double?> values;
  final double rangeCents;
  final Color lineColor;
  final Color targetColor;
  final Color gridColor;

  const _PitchCurvePainter({
    required this.values,
    required this.rangeCents,
    required this.lineColor,
    required this.targetColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final Paint zeroPaint = Paint()
      ..color = targetColor
      ..strokeWidth = 1.8;
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i <= 4; i++) {
      final double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final double zeroY = size.height / 2;
    canvas.drawLine(Offset(0, zeroY), Offset(size.width, zeroY), zeroPaint);

    if (values.length < 2) {
      return;
    }
    final double dx = size.width / (values.length - 1);
    Path? path;
    for (int i = 0; i < values.length; i++) {
      final double? value = values[i];
      if (value == null) {
        if (path != null) {
          canvas.drawPath(path, linePaint);
          path = null;
        }
        continue;
      }
      final double clamped = value.clamp(-rangeCents, rangeCents);
      final double y = zeroY - (clamped / rangeCents) * (size.height / 2);
      final double x = i * dx;
      path ??= Path()..moveTo(x, y);
      path.lineTo(x, y);
    }
    if (path != null) {
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PitchCurvePainter oldDelegate) {
    return oldDelegate.rangeCents != rangeCents ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.targetColor != targetColor ||
        oldDelegate.gridColor != gridColor ||
        !listEquals(oldDelegate.values, values);
  }
}
