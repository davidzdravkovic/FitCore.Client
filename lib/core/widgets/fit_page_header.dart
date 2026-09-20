import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:flutter/material.dart';

/// Title block that opens every operational page: what this page is, plus the
/// actions that belong to it. Stacks under the compact breakpoint.
class FitPageHeader extends StatelessWidget {
  const FitPageHeader({
    super.key,
    required this.title,
    this.description,
    this.meta,
    this.actions = const <Widget>[],
    this.dense = false,
  });

  final String title;
  final String? description;

  /// Short supporting line, e.g. a record count already known to the caller.
  final Widget? meta;
  final List<Widget> actions;

  /// Phone-dense: smaller title, optional description omitted by caller,
  /// actions sit in one horizontal row instead of full-width stacks.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final stacked = width < FitCoreBreakpoints.compact;

        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: dense
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (meta != null) ...[
                  const SizedBox(width: FitCoreSpace.x3),
                  meta!,
                ],
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: FitCoreSpace.x1),
              Text(
                description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                ),
              ),
            ],
          ],
        );

        if (actions.isEmpty) return text;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              text,
              SizedBox(height: dense ? FitCoreSpace.x2 : FitCoreSpace.x3),
              Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: FitCoreSpace.x2),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: text),
            const SizedBox(width: FitCoreSpace.x4),
            Wrap(
              spacing: FitCoreSpace.x2,
              runSpacing: FitCoreSpace.x2,
              alignment: WrapAlignment.end,
              children: actions,
            ),
          ],
        );
      },
    );
  }
}

/// Small muted counter used next to a page or panel title.
class FitCountBadge extends StatelessWidget {
  const FitCountBadge({super.key, required this.count, this.noun});

  final int count;
  final String? noun;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    final label = noun == null ? '$count' : '$count ${noun!}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FitCoreSpace.x2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: t.elevated,
        borderRadius: BorderRadius.circular(FitCoreRadius.xs),
        border: Border.all(color: t.borderSubtle),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: t.textSecondary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
