import 'dart:math';

import 'package:flutter/material.dart';

/// 波形可视化组件，可用于实时录音或回放进度展示。
class WaveformView extends StatelessWidget {
  /// 归一化峰值数据，约定范围 [0, 1]。
  final List<double> peaks;

  /// 播放进度，范围 [0, 1]；仅 `live=false` 时生效。
  final double progress;

  /// 是否实时模式；实时模式下不绘制进度游标。
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
        ..color = color.withValues(alpha: 0.35)
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
    const double minBarHeight = 0.3;
    const double lowAmpAttenuation = 2.4;
    const double highAmpBoostStart = 0.78;
    const double highAmpBoost = 1.12;
    final double playedX = size.width * progress.clamp(0.0, 1.0);
    for (int i = 0; i < count; i++) {
      final double x = (i * widthPerBar) + (widthPerBar * 0.5);
      final double peak = peaks[i].clamp(0.0, 1.0);
      // 低幅值抑制 + 高频段轻微增强，提升视觉层次并保留重音冲击感。
      double shapedPeak = pow(peak, lowAmpAttenuation).toDouble();
      if (peak >= highAmpBoostStart) {
        shapedPeak = (shapedPeak * highAmpBoost).clamp(0.0, 1.0);
      }
      final double bar = max(minBarHeight, shapedPeak * maxBarHeight);
      final Offset p1 = Offset(x, (size.height * 0.5) - bar);
      final Offset p2 = Offset(x, (size.height * 0.5) + bar);
      final Paint paint = !live && x <= playedX ? playedPaint : basePaint;
      canvas.drawLine(p1, p2, paint);
    }
    if (!live) {
      final Paint cursor = Paint()
        ..color = progressColor.withValues(alpha: 0.75)
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
