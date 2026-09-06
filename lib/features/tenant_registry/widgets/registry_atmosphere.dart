import 'dart:math' as math;

import 'package:flutter/material.dart';

class RegistryAtmosphere extends StatelessWidget {
  const RegistryAtmosphere({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final dx = math.sin(t * math.pi * 2) * 28;
        final dy = math.cos(t * math.pi * 2) * 18;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                Color.lerp(
                      colorScheme.surface,
                      colorScheme.primaryContainer,
                      0.22,
                    ) ??
                    colorScheme.surface,
                colorScheme.surface,
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _GridPainter(
                  color: colorScheme.onSurface.withValues(alpha: 0.045),
                ),
              ),
              Positioned(
                left: -80 + dx,
                top: -40 + dy,
                child: _GlowOrb(
                  diameter: 340,
                  color: colorScheme.primary.withValues(alpha: 0.16),
                ),
              ),
              Positioned(
                right: -60 - dx,
                bottom: 40 - dy,
                child: _GlowOrb(
                  diameter: 280,
                  color: colorScheme.tertiary.withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                right: 18,
                top: 72,
                child: _GlowOrb(
                  diameter: 120,
                  color: colorScheme.secondary.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
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

    const step = 48.0;
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
