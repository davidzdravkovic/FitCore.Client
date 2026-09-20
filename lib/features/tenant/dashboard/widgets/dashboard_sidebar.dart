import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/features/tenant/dashboard/navigation/dashboard_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    required this.selected,
    required this.organizationName,
    this.closeDrawerOnSelect = false,
  });

  final DashboardSection selected;
  final String organizationName;
  final bool closeDrawerOnSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return ColoredBox(
      color: t.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              FitCoreSpace.x5,
              FitCoreSpace.x5,
              FitCoreSpace.x4,
              FitCoreSpace.x4,
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: t.borderSubtle)),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(FitCoreRadius.sm),
                    border: Border.all(color: t.accent.withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    'F',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: t.accent,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: FitCoreSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FitCore',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: t.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        organizationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: t.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: FitCoreSpace.x2,
                vertical: FitCoreSpace.x3,
              ),
              itemCount: dashboardNavItems.length,
              itemBuilder: (context, index) {
                final item = dashboardNavItems[index];

                return _NavTile(
                  item: item,
                  isSelected: item.section == selected,
                  onTap: () {
                    context.go(item.section.location);
                    if (closeDrawerOnSelect) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final DashboardNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final selected = widget.isSelected;

    final fg = selected
        ? t.textPrimary
        : (_hovered ? t.textPrimary : t.textSecondary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Semantics(
          selected: selected,
          button: true,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(FitCoreRadius.sm),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 110),
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: FitCoreSpace.x2),
              decoration: BoxDecoration(
                color: selected
                    ? t.accent.withValues(alpha: 0.10)
                    : (_hovered ? t.rowHover : Colors.transparent),
                borderRadius: BorderRadius.circular(FitCoreRadius.sm),
              ),
              child: Row(
                children: [
                  Container(
                    width: 2,
                    height: 16,
                    decoration: BoxDecoration(
                      color: selected ? t.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: FitCoreSpace.x3),
                  Icon(
                    widget.item.icon,
                    size: 17,
                    color: selected ? t.accent : fg,
                  ),
                  const SizedBox(width: FitCoreSpace.x3),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
