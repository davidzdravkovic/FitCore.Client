import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:flutter/material.dart';

/// Quiet metric tile: value first, then what it counts, then how it is counted.
class OverviewStatCard extends StatelessWidget {
  const OverviewStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
    this.hint,
    this.isLoading = false,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;
  final String? hint;
  final bool isLoading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final tint = accent ?? t.accent;
    final pad = compact ? FitCoreSpace.x3 : FitCoreSpace.x4;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: BorderRadius.circular(FitCoreRadius.lg),
        border: Border.all(color: t.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: compact ? 14 : 15, color: tint),
              const SizedBox(width: FitCoreSpace.x2),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: t.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    fontSize: compact ? 10 : 11,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? FitCoreSpace.x2 : FitCoreSpace.x4),
          if (isLoading)
            Container(
              height: compact ? 22 : 26,
              width: 56,
              decoration: BoxDecoration(
                color: t.elevated,
                borderRadius: BorderRadius.circular(FitCoreRadius.xs),
              ),
            )
          else
            Text(
              value,
              style: (compact
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.displaySmall)
                  ?.copyWith(
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          if (hint != null && !compact) ...[
            const SizedBox(height: FitCoreSpace.x2),
            Text(
              hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: t.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
