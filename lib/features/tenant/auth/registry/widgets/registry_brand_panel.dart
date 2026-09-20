import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
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
    final t = context.fc;
    final align = compact
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = compact ? TextAlign.center : TextAlign.start;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? FitCoreSpace.x1 : FitCoreSpace.x10,
        vertical: compact ? FitCoreSpace.x2 : 56,
      ),
      child: Column(
        crossAxisAlignment: align,
        mainAxisAlignment: compact
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 26 : 30,
                height: compact ? 26 : 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(FitCoreRadius.md),
                  border: Border.all(color: t.accent.withValues(alpha: 0.45)),
                ),
                child: Text(
                  'F',
                  style: GoogleFonts.outfit(
                    fontSize: compact ? 15 : 17,
                    fontWeight: FontWeight.w700,
                    color: t.accent,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: FitCoreSpace.x3),
              Text(
                'FitCore',
                style: GoogleFonts.outfit(
                  fontSize: compact ? 26 : 32,
                  fontWeight: FontWeight.w600,
                  height: 1.05,
                  letterSpacing: -0.9,
                  color: t.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? FitCoreSpace.x5 : FitCoreSpace.x8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              'Register your gym',
              textAlign: textAlign,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          SizedBox(height: compact ? FitCoreSpace.x2 : FitCoreSpace.x3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              'Create your gym account and get started in a few minutes.',
              textAlign: textAlign,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          if (!hasToken) ...[
            SizedBox(height: compact ? FitCoreSpace.x4 : FitCoreSpace.x5),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FitCoreSpace.x3,
                vertical: FitCoreSpace.x2,
              ),
              decoration: BoxDecoration(
                color: t.stateNegative.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(FitCoreRadius.md),
                border: Border.all(
                  color: t.stateNegative.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                'Open this page from your invitation email link.',
                textAlign: textAlign,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: t.stateNegative,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
