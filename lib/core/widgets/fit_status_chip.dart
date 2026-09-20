import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:flutter/material.dart';

/// Visual weight of a status, independent of any domain.
///
/// Features map their own existing statuses onto a tone; this file never
/// decides what a status means.
enum FitTone { neutral, info, positive, caution, warning, negative, muted }

class FitStatusChip extends StatelessWidget {
  const FitStatusChip({
    super.key,
    required this.label,
    this.tone = FitTone.neutral,
    this.color,
    this.dense = false,
  });

  /// Chip driven by an explicit color (used where a feature already owns a
  /// status palette, e.g. visit tones).
  const FitStatusChip.colored({
    super.key,
    required this.label,
    required Color this.color,
    this.dense = false,
  }) : tone = FitTone.neutral;

  final String label;
  final FitTone tone;
  final Color? color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    final accent = color ?? tone.resolve(t);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? FitCoreSpace.x2 : 10,
        vertical: dense ? 2 : FitCoreSpace.x1,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(FitCoreRadius.sm),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: FitCoreSpace.x2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
              fontSize: dense ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

extension FitToneColor on FitTone {
  Color resolve(FitCoreTokens t) => switch (this) {
    FitTone.neutral => t.stateNeutral,
    FitTone.info => t.accent,
    FitTone.positive => t.statePositive,
    FitTone.caution => t.stateTrial,
    FitTone.warning => t.statePaused,
    FitTone.negative => t.stateNegative,
    FitTone.muted => t.textMuted,
  };
}
