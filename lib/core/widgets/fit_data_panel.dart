import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:flutter/material.dart';

/// Bordered surface that holds a body of records.
///
/// Chrome only: the caller decides what goes inside (table, board, state).
class FitDataPanel extends StatelessWidget {
  const FitDataPanel({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.toolbar,
    this.footer,
    this.padded = false,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;

  /// Row placed under the panel title, e.g. a legend the feature already has.
  final Widget? toolbar;
  final Widget? footer;

  /// Pads the body. Tables manage their own insets, so this defaults to false.
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final hasHead = title != null || trailing != null || toolbar != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: BorderRadius.circular(FitCoreRadius.lg),
        border: Border.all(color: t.borderSubtle),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FitCoreRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasHead)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FitCoreSpace.x4,
                  vertical: FitCoreSpace.x3,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: t.borderSubtle)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title != null || trailing != null)
                      Row(
                        children: [
                          if (title != null)
                            Expanded(
                              child: Text(
                                title!,
                                style: theme.textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            const Spacer(),
                          ?trailing,
                        ],
                      ),
                    if (toolbar != null) ...[
                      if (title != null || trailing != null)
                        const SizedBox(height: FitCoreSpace.x3),
                      toolbar!,
                    ],
                  ],
                ),
              ),
            Expanded(
              child: padded
                  ? Padding(
                      padding: const EdgeInsets.all(FitCoreSpace.x4),
                      child: child,
                    )
                  : child,
            ),
            if (footer != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FitCoreSpace.x4,
                  vertical: FitCoreSpace.x2,
                ),
                decoration: BoxDecoration(
                  color: t.canvas,
                  border: Border(top: BorderSide(color: t.borderSubtle)),
                ),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Width for dialog content so forms never overflow a phone screen.
double fitDialogWidth(BuildContext context, {double max = 420}) {
  final available = MediaQuery.sizeOf(context).width - 96;
  return available < max ? (available < 240 ? 240 : available) : max;
}

/// Page scaffold used by every tenant section: header, gap, panel.
class FitPageBody extends StatelessWidget {
  const FitPageBody({
    super.key,
    required this.header,
    required this.child,
    this.maxWidth = double.infinity,
  });

  final Widget header;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.medium;
    final phone =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;
    final pad = phone
        ? FitCoreSpace.x3
        : (compact ? FitCoreSpace.x4 : FitCoreSpace.x6);

    final content = Padding(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          SizedBox(height: compact ? FitCoreSpace.x3 : FitCoreSpace.x5),
          Expanded(child: child),
        ],
      ),
    );

    // Always claim the shell width first. Optional maxWidth only caps on
    // very wide desktops — never shrink-wrap on phones.
    return SizedBox(
      width: double.infinity,
      child: maxWidth.isFinite
          ? Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SizedBox(width: double.infinity, child: content),
              ),
            )
          : content,
    );
  }
}
