import 'package:flutter/material.dart';

class GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const GlowOrb({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.02),
          ],
        ),
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;
  final Widget? child;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: child ??
                Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
          ),
        ),
      ),
    );
  }
}

class CloudBurst {
  final Offset center;
  final double radius;
  final int startMs;
  final int durationMs;
  final double driftX;
  final double driftY;
  final Color color;

  const CloudBurst({
    required this.center,
    required this.radius,
    required this.startMs,
    required this.durationMs,
    required this.driftX,
    required this.driftY,
    required this.color,
  });
}

class CloudBurstPainter extends CustomPainter {
  final List<CloudBurst> bursts;
  final int nowMs;

  CloudBurstPainter({
    required this.bursts,
    required this.nowMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final burst in bursts) {
      final double t =
          ((nowMs - burst.startMs) / burst.durationMs).clamp(0.0, 1.0);
      final double ease = Curves.easeOutCubic.transform(t);
      final Offset center = Offset(
        burst.center.dx * size.width + burst.driftX * ease,
        burst.center.dy * size.height + burst.driftY * ease,
      );
      final double radius = burst.radius * (0.6 + ease * 0.8);
      final double opacity = (1 - ease) * 0.16;
      final Paint paint = Paint()
        ..color = burst.color.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.25);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CloudBurstPainter oldDelegate) {
    return true;
  }
}
