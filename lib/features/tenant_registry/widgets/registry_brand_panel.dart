import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistryBrandPanel extends StatelessWidget {
  const RegistryBrandPanel({
    super.key,
    required this.hasToken,
    this.compact = false,
  });

  final bool hasToken;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 48,
        vertical: compact ? 8 : 56,
      ),
      child: Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisAlignment:
            compact ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Text(
            'FitCore',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.outfit(
              fontSize: compact ? 42 : 64,
              fontWeight: FontWeight.w700,
              height: 1.05,
              letterSpacing: -1.4,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: compact ? 10 : 16),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 360 : 340),
            child: Text(
              'Register your gym',
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
                color: colorScheme.onSurface.withValues(alpha: 0.88),
              ),
            ),
          ),
          SizedBox(height: compact ? 8 : 14),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 360 : 340),
            child: Text(
              'Create your gym account and get started in a few minutes.',
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (!hasToken) ...[
            SizedBox(height: compact ? 14 : 20),
            Text(
              'Open this page from your invitation email link.',
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (!compact) ...[
            const SizedBox(height: 36),
            _AccentRule(color: colorScheme.primary),
          ],
        ],
      ),
    );
  }
}

class _AccentRule extends StatefulWidget {
  const _AccentRule({required this.color});

  final Color color;

  @override
  State<_AccentRule> createState() => _AccentRuleState();
}

class _AccentRuleState extends State<_AccentRule>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _width = Tween<double>(begin: 0, end: 72).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _width,
      builder: (context, _) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: _width.value,
            height: 3,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}
