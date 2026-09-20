import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:flutter/material.dart';

/// Nothing to show yet. Copy comes from the caller; this adds no new meaning.
class FitEmptyState extends StatelessWidget {
  const FitEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(FitCoreSpace.x8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: t.elevated,
                    borderRadius: BorderRadius.circular(FitCoreRadius.md),
                    border: Border.all(color: t.borderDefault),
                  ),
                  child: Icon(icon, size: 20, color: t.textMuted),
                ),
                const SizedBox(height: FitCoreSpace.x4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
                if (message != null) ...[
                  const SizedBox(height: FitCoreSpace.x2),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: FitCoreSpace.x5),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Load failure with a retry affordance. The message is the server's copy.
class FitErrorState extends StatelessWidget {
  const FitErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Could not load',
  });

  final String message;
  final VoidCallback? onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(FitCoreSpace.x6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(FitCoreSpace.x4),
                  decoration: BoxDecoration(
                    color: t.stateNegative.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(FitCoreRadius.md),
                    border: Border.all(
                      color: t.stateNegative.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 18,
                        color: t.stateNegative,
                      ),
                      const SizedBox(width: FitCoreSpace.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: theme.textTheme.titleSmall),
                            const SizedBox(height: FitCoreSpace.x1),
                            Text(
                              message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: t.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: FitCoreSpace.x4),
                  Align(
                    alignment: Alignment.center,
                    child: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline error strip for surfaces that keep their content while failing.
class FitErrorBanner extends StatelessWidget {
  const FitErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        FitCoreSpace.x4,
        FitCoreSpace.x3,
        FitCoreSpace.x2,
        FitCoreSpace.x3,
      ),
      decoration: BoxDecoration(
        color: t.stateNegative.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(FitCoreRadius.md),
        border: Border.all(color: t.stateNegative.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: t.stateNegative),
          const SizedBox(width: FitCoreSpace.x3),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: t.textPrimary),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: FitCoreSpace.x2),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

/// Row-shaped placeholder that keeps the layout stable while data loads.
class FitTableSkeleton extends StatefulWidget {
  const FitTableSkeleton({
    super.key,
    this.rows = 6,
    this.columnFlex = const [3, 3, 2, 2],
  });

  final int rows;
  final List<int> columnFlex;

  @override
  State<FitTableSkeleton> createState() => _FitTableSkeletonState();
}

class _FitTableSkeletonState extends State<FitTableSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final alpha = reduceMotion ? 0.5 : 0.35 + (_pulse.value * 0.35);

        return ListView.builder(
          primary: false,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.rows,
          itemBuilder: (context, row) {
            return _skeletonRow(t, alpha);
          },
        );
      },
    );
  }

  Widget _skeletonRow(FitCoreTokens t, double alpha) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: FitCoreSpace.x4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.borderSubtle)),
      ),
      child: Row(
        children: [
          for (var col = 0; col < widget.columnFlex.length; col++)
            Expanded(
              flex: widget.columnFlex[col],
              child: Padding(
                padding: const EdgeInsets.only(right: FitCoreSpace.x6),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: t.elevated.withValues(alpha: alpha),
                    borderRadius: BorderRadius.circular(FitCoreRadius.xs),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
