import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:flutter/material.dart';

/// Quiet backdrop for the registry page: flat canvas, a hairline grid, and a
/// single low-contrast accent wash that drifts a few pixels.
class RegistryAtmosphere extends StatelessWidget {
  const RegistryAtmosphere({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ColoredBox(
          color: t.canvas,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _GridPainter(color: t.borderSubtle)),
              Align(
                alignment: Alignment(-0.9, -1 + (animation.value * 0.04)),
                child: IgnorePointer(
                  child: Container(
                    width: 420,
                    height: 420,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          t.accent.withValues(alpha: 0.07),
                          t.accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const step = 56.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color;
}
