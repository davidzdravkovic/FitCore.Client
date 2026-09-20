import 'package:flutter/material.dart';

/// FitCore design tokens.
///
/// Presentation only: nothing here reads or writes app state. Status colors
/// mirror the operational states the API already returns (visits, members,
/// memberships, service/plan activity).
@immutable
class FitCoreTokens extends ThemeExtension<FitCoreTokens> {
  const FitCoreTokens({
    required this.canvas,
    required this.sidebar,
    required this.panel,
    required this.elevated,
    required this.rowHover,
    required this.borderDefault,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.visitScheduled,
    required this.visitCompleted,
    required this.visitNoShow,
    required this.visitCancelled,
    required this.visitVoided,
    required this.stateNeutral,
    required this.stateTrial,
    required this.statePaused,
    required this.statePositive,
    required this.stateNegative,
  });

  final Color canvas;
  final Color sidebar;
  final Color panel;
  final Color elevated;
  final Color rowHover;

  final Color borderDefault;
  final Color borderSubtle;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color accent;
  final Color onAccent;

  final Color visitScheduled;
  final Color visitCompleted;
  final Color visitNoShow;
  final Color visitCancelled;
  final Color visitVoided;

  final Color stateNeutral;
  final Color stateTrial;
  final Color statePaused;
  final Color statePositive;
  final Color stateNegative;

  /// Original FitCore cool charcoal + blue accent.
  static const FitCoreTokens dark = FitCoreTokens(
    canvas: Color(0xFF0E1116),
    sidebar: Color(0xFF0C0F14),
    panel: Color(0xFF141922),
    elevated: Color(0xFF1A212B),
    rowHover: Color(0xFF1C2430),
    borderDefault: Color(0xFF2A3340),
    borderSubtle: Color(0xFF1C2430),
    textPrimary: Color(0xFFE8EDF4),
    textSecondary: Color(0xFF9AA6B5),
    textMuted: Color(0xFF6B7788),
    accent: Color(0xFF4C8DFF),
    onAccent: Color(0xFFF4F7FB),
    visitScheduled: Color(0xFF4C8DFF),
    visitCompleted: Color(0xFF3BB273),
    visitNoShow: Color(0xFF9B6BD8),
    visitCancelled: Color(0xFFE2624F),
    visitVoided: Color(0xFF8A94A6),
    stateNeutral: Color(0xFF6B7788),
    stateTrial: Color(0xFFC9A227),
    statePaused: Color(0xFFD08B4C),
    statePositive: Color(0xFF3BB273),
    stateNegative: Color(0xFFE2624F),
  );

  @override
  FitCoreTokens copyWith({
    Color? canvas,
    Color? sidebar,
    Color? panel,
    Color? elevated,
    Color? rowHover,
    Color? borderDefault,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? onAccent,
    Color? visitScheduled,
    Color? visitCompleted,
    Color? visitNoShow,
    Color? visitCancelled,
    Color? visitVoided,
    Color? stateNeutral,
    Color? stateTrial,
    Color? statePaused,
    Color? statePositive,
    Color? stateNegative,
  }) {
    return FitCoreTokens(
      canvas: canvas ?? this.canvas,
      sidebar: sidebar ?? this.sidebar,
      panel: panel ?? this.panel,
      elevated: elevated ?? this.elevated,
      rowHover: rowHover ?? this.rowHover,
      borderDefault: borderDefault ?? this.borderDefault,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      visitScheduled: visitScheduled ?? this.visitScheduled,
      visitCompleted: visitCompleted ?? this.visitCompleted,
      visitNoShow: visitNoShow ?? this.visitNoShow,
      visitCancelled: visitCancelled ?? this.visitCancelled,
      visitVoided: visitVoided ?? this.visitVoided,
      stateNeutral: stateNeutral ?? this.stateNeutral,
      stateTrial: stateTrial ?? this.stateTrial,
      statePaused: statePaused ?? this.statePaused,
      statePositive: statePositive ?? this.statePositive,
      stateNegative: stateNegative ?? this.stateNegative,
    );
  }

  @override
  FitCoreTokens lerp(ThemeExtension<FitCoreTokens>? other, double t) {
    if (other is! FitCoreTokens) return this;
    return FitCoreTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      rowHover: Color.lerp(rowHover, other.rowHover, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      visitScheduled: Color.lerp(visitScheduled, other.visitScheduled, t)!,
      visitCompleted: Color.lerp(visitCompleted, other.visitCompleted, t)!,
      visitNoShow: Color.lerp(visitNoShow, other.visitNoShow, t)!,
      visitCancelled: Color.lerp(visitCancelled, other.visitCancelled, t)!,
      visitVoided: Color.lerp(visitVoided, other.visitVoided, t)!,
      stateNeutral: Color.lerp(stateNeutral, other.stateNeutral, t)!,
      stateTrial: Color.lerp(stateTrial, other.stateTrial, t)!,
      statePaused: Color.lerp(statePaused, other.statePaused, t)!,
      statePositive: Color.lerp(statePositive, other.statePositive, t)!,
      stateNegative: Color.lerp(stateNegative, other.stateNegative, t)!,
    );
  }
}

/// Spacing, radius and layout metrics shared by every FitCore surface.
class FitCoreSpace {
  FitCoreSpace._();

  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
}

class FitCoreRadius {
  FitCoreRadius._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
}

/// Breakpoints for adaptive presentation across web/desktop, Android and iOS.
class FitCoreBreakpoints {
  FitCoreBreakpoints._();

  /// Below this width tables present as stacked rows.
  static const double compact = 640;

  /// Below this width the shell uses a drawer instead of a fixed sidebar.
  static const double medium = 960;

  /// Content stops growing past this width so rows stay scannable.
  static const double expanded = 1280;
}

extension FitCoreThemeX on BuildContext {
  /// FitCore tokens for the active theme.
  FitCoreTokens get fc =>
      Theme.of(this).extension<FitCoreTokens>() ?? FitCoreTokens.dark;
}
