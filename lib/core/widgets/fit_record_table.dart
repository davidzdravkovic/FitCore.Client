import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:flutter/material.dart';

/// A column in a record table. `hideBelow` lets low-priority columns drop out
/// on narrower viewports instead of forcing a horizontal scroll.
class FitColumn {
  const FitColumn({
    required this.label,
    this.flex = 2,
    this.minWidth = 140,
    this.hideBelow,
  });

  final String label;
  final int flex;
  final double minWidth;
  final double? hideBelow;
}

/// One record. `cells` must line up with the table's columns.
class FitRecordRow {
  const FitRecordRow({
    required this.cells,
    this.leading,
    this.actions = const <Widget>[],
    this.depth = 0,
  });

  final List<Widget> cells;
  final Widget? leading;
  final List<Widget> actions;

  /// Nested child rows (tree-grid). 0 is a top-level record.
  final int depth;
}

/// Dense, scannable record list.
///
/// Wide viewports get an aligned table with hairline row separators and hover
/// feedback; compact viewports get stacked records with labelled fields so the
/// same information survives on a phone. Purely presentational — it renders
/// whatever the caller passes.
class FitRecordTable extends StatelessWidget {
  const FitRecordTable({
    super.key,
    required this.columns,
    required this.rows,
    this.leadingWidth = 36,
    this.shrinkWrap = true,
    this.stackBelow = FitCoreBreakpoints.compact,
  });

  final List<FitColumn> columns;
  final List<FitRecordRow> rows;
  final double leadingWidth;

  /// Size to children instead of filling the parent. Use when the table sits
  /// inside another scroll view (nested catalog sections).
  final bool shrinkWrap;

  /// Below this width, rows stack labelled fields instead of columns.
  final double stackBelow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < stackBelow) {
          return _CompactList(
            columns: columns,
            rows: rows,
            leadingWidth: leadingWidth,
            shrinkWrap: shrinkWrap,
          );
        }

        final visible = <int>[
          for (var i = 0; i < columns.length; i++)
            if (columns[i].hideBelow == null || width >= columns[i].hideBelow!)
              i,
        ];

        final actionCount = rows.fold<int>(
          0,
          (max, row) => row.actions.length > max ? row.actions.length : max,
        );
        final actionsWidth = actionCount == 0 ? 0.0 : (actionCount * 44) + 8.0;
        final hasLeading = rows.any((row) => row.leading != null);
        final fixed =
            actionsWidth + (hasLeading ? leadingWidth + FitCoreSpace.x3 : 0.0);
        final minBody = visible.fold<double>(
          0,
          (sum, i) => sum + columns[i].minWidth,
        );
        final minWidth = minBody + fixed + (FitCoreSpace.x4 * 2);

        final table = _WideTable(
          columns: columns,
          visible: visible,
          rows: rows,
          actionsWidth: actionsWidth,
          leadingWidth: hasLeading ? leadingWidth : 0.0,
          shrinkWrap: shrinkWrap,
        );

        if (minWidth <= width) return table;

        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: minWidth, child: table),
          ),
        );
      },
    );
  }
}

class _WideTable extends StatelessWidget {
  const _WideTable({
    required this.columns,
    required this.visible,
    required this.rows,
    required this.actionsWidth,
    required this.leadingWidth,
    required this.shrinkWrap,
  });

  final List<FitColumn> columns;
  final List<int> visible;
  final List<FitRecordRow> rows;
  final double actionsWidth;
  final double leadingWidth;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: FitCoreSpace.x4),
          decoration: BoxDecoration(
            color: t.canvas,
            border: Border(bottom: BorderSide(color: t.borderDefault)),
          ),
          child: Row(
            children: [
              if (leadingWidth > 0)
                SizedBox(width: leadingWidth + FitCoreSpace.x3),
              for (final i in visible)
                Expanded(
                  flex: columns[i].flex,
                  child: Padding(
                    padding: const EdgeInsets.only(right: FitCoreSpace.x4),
                    child: Text(
                      columns[i].label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: t.textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              if (actionsWidth > 0) SizedBox(width: actionsWidth),
            ],
          ),
        ),
        if (shrinkWrap)
          for (var index = 0; index < rows.length; index++)
            _WideRow(
              row: rows[index],
              columns: columns,
              visible: visible,
              actionsWidth: actionsWidth,
              leadingWidth: leadingWidth,
              isLast: index == rows.length - 1,
            )
        else
          Expanded(
            child: ListView.builder(
              primary: false,
              padding: EdgeInsets.zero,
              itemCount: rows.length,
              itemBuilder: (context, index) {
                return _WideRow(
                  row: rows[index],
                  columns: columns,
                  visible: visible,
                  actionsWidth: actionsWidth,
                  leadingWidth: leadingWidth,
                  isLast: index == rows.length - 1,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _WideRow extends StatefulWidget {
  const _WideRow({
    required this.row,
    required this.columns,
    required this.visible,
    required this.actionsWidth,
    required this.leadingWidth,
    required this.isLast,
  });

  final FitRecordRow row;
  final List<FitColumn> columns;
  final List<int> visible;
  final double actionsWidth;
  final double leadingWidth;
  final bool isLast;

  @override
  State<_WideRow> createState() => _WideRowState();
}

class _WideRowState extends State<_WideRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: FitCoreSpace.x4,
          vertical: FitCoreSpace.x2,
        ),
        decoration: BoxDecoration(
          color: _hovered ? t.rowHover : Colors.transparent,
          border: widget.isLast
              ? null
              : Border(bottom: BorderSide(color: t.borderSubtle)),
        ),
        child: Row(
          children: [
            if (widget.leadingWidth > 0) ...[
              SizedBox(width: widget.leadingWidth, child: widget.row.leading),
              const SizedBox(width: FitCoreSpace.x3),
            ],
            for (final i in widget.visible)
              Expanded(
                flex: widget.columns[i].flex,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == widget.visible.first
                        ? widget.row.depth * 20.0
                        : 0,
                    right: FitCoreSpace.x4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: widget.row.cells[i],
                  ),
                ),
              ),
            if (widget.actionsWidth > 0)
              SizedBox(
                width: widget.actionsWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: widget.row.actions,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompactList extends StatelessWidget {
  const _CompactList({
    required this.columns,
    required this.rows,
    required this.leadingWidth,
    required this.shrinkWrap,
  });

  final List<FitColumn> columns;
  final List<FitRecordRow> rows;
  final double leadingWidth;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    Widget item(int index) {
      final row = rows[index];

      return Container(
        padding: EdgeInsets.fromLTRB(
          FitCoreSpace.x4 + row.depth * 20.0,
          FitCoreSpace.x4,
          FitCoreSpace.x4,
          FitCoreSpace.x4,
        ),
        decoration: BoxDecoration(
          border: index == rows.length - 1
              ? null
              : Border(bottom: BorderSide(color: t.borderSubtle)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (row.leading != null) ...[
                  SizedBox(width: leadingWidth, child: row.leading),
                  const SizedBox(width: FitCoreSpace.x3),
                ],
                Expanded(child: row.cells.first),
              ],
            ),
            for (var i = 1; i < columns.length; i++) ...[
              const SizedBox(height: FitCoreSpace.x2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      columns[i].label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: t.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: FitCoreSpace.x2),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: row.cells[i],
                    ),
                  ),
                ],
              ),
            ],
            if (row.actions.isNotEmpty) ...[
              const SizedBox(height: FitCoreSpace.x2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: row.actions,
              ),
            ],
          ],
        ),
      );
    }

    if (shrinkWrap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < rows.length; index++) item(index),
        ],
      );
    }

    return ListView.builder(
      primary: false,
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      itemBuilder: (context, index) => item(index),
    );
  }
}

/// Text cell with the table's typographic roles.
class FitTextCell extends StatelessWidget {
  const FitTextCell(
    this.text, {
    super.key,
    this.strong = false,
    this.muted = false,
    this.mono = false,
    this.maxLines = 1,
  });

  /// Placeholder cell for a value the record does not carry.
  const FitTextCell.empty({super.key})
    : text = '—',
      strong = false,
      muted = true,
      mono = false,
      maxLines = 1;

  final String text;
  final bool strong;
  final bool muted;
  final bool mono;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    final style =
        (strong ? theme.textTheme.labelLarge : theme.textTheme.bodyMedium)
            ?.copyWith(
              color: muted ? t.textSecondary : t.textPrimary,
              fontFeatures: mono ? const [FontFeature.tabularFigures()] : null,
            );

    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

/// Compact icon action sized for touch on Android and iOS.
class FitRowAction extends StatelessWidget {
  const FitRowAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.danger = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    final enabled = onPressed != null;

    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: 18,
        color: danger ? t.stateNegative : t.textSecondary,
        disabledColor: t.textMuted.withValues(alpha: 0.5),
        icon: Icon(icon),
        style: ButtonStyle(
          overlayColor: WidgetStatePropertyAll(
            enabled ? t.borderDefault.withValues(alpha: 0.5) : null,
          ),
        ),
      ),
    );
  }
}

/// Initials badge used as the leading element of a person record.
class FitAvatar extends StatelessWidget {
  const FitAvatar({super.key, required this.name, this.size = 32});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    final trimmed = name.trim();
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.isEmpty
        ? '—'
        : parts.take(2).map((p) => p[0].toUpperCase()).join();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.elevated,
        borderRadius: BorderRadius.circular(FitCoreRadius.sm),
        border: Border.all(color: t.borderDefault),
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: t.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: size <= 28 ? 11 : 12,
        ),
      ),
    );
  }
}
