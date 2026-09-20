import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the FitCore operational-CRM theme.
///
/// Cool charcoal surfaces, blue accent, hairline borders and
/// tight radii. Presentation only — no behavior depends on this file.
class FitCoreTheme {
  FitCoreTheme._();

  static ThemeData dark() => _build(FitCoreTokens.dark);

  static ThemeData _build(FitCoreTokens t) {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: t.accent,
      onPrimary: t.onAccent,
      primaryContainer: t.elevated,
      onPrimaryContainer: t.textPrimary,
      secondary: t.textSecondary,
      onSecondary: t.canvas,
      secondaryContainer: t.elevated,
      onSecondaryContainer: t.textPrimary,
      tertiary: t.visitCompleted,
      onTertiary: t.canvas,
      error: t.stateNegative,
      onError: t.onAccent,
      errorContainer: t.elevated,
      onErrorContainer: t.stateNegative,
      surface: t.canvas,
      onSurface: t.textPrimary,
      onSurfaceVariant: t.textSecondary,
      surfaceContainerLowest: t.sidebar,
      surfaceContainerLow: t.canvas,
      surfaceContainer: t.panel,
      surfaceContainerHigh: t.elevated,
      surfaceContainerHighest: t.rowHover,
      outline: t.borderDefault,
      outlineVariant: t.borderSubtle,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: t.textPrimary,
      onInverseSurface: t.canvas,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: t.canvas,
      canvasColor: t.canvas,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = _textTheme(base.textTheme, t);

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[t],
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: t.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      dividerColor: t.borderSubtle,
      appBarTheme: AppBarTheme(
        backgroundColor: t.panel,
        foregroundColor: t.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: CardThemeData(
        color: t.panel,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoreRadius.md),
          side: BorderSide(color: t.borderSubtle),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: t.sidebar,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.panel,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoreRadius.xl),
          side: BorderSide(color: t.borderDefault),
        ),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.elevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: t.textPrimary),
        actionTextColor: t.accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoreRadius.md),
          side: BorderSide(color: t.borderDefault),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.elevated,
          borderRadius: BorderRadius.circular(FitCoreRadius.sm),
          border: Border.all(color: t.borderDefault),
        ),
        textStyle: textTheme.labelSmall?.copyWith(color: t.textPrimary),
        waitDuration: const Duration(milliseconds: 400),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.elevated,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FitCoreSpace.x3,
          vertical: FitCoreSpace.x3,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: t.textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(color: t.accent),
        helperStyle: textTheme.labelSmall?.copyWith(color: t.textMuted),
        errorStyle: textTheme.labelSmall?.copyWith(color: t.stateNegative),
        border: _inputBorder(t.borderDefault),
        enabledBorder: _inputBorder(t.borderDefault),
        disabledBorder: _inputBorder(t.borderSubtle),
        focusedBorder: _inputBorder(t.accent, width: 1.5),
        errorBorder: _inputBorder(t.stateNegative),
        focusedErrorBorder: _inputBorder(t.stateNegative, width: 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return t.elevated;
            if (states.contains(WidgetState.hovered)) {
              return Color.lerp(t.accent, Colors.white, 0.12);
            }
            return t.accent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return t.textMuted;
            return t.onAccent;
          }),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: FitCoreSpace.x4,
              vertical: FitCoreSpace.x3,
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FitCoreRadius.md),
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return t.textMuted;
            return t.textPrimary;
          }),
          overlayColor: WidgetStatePropertyAll(t.rowHover),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return BorderSide(color: t.accent);
            }
            return BorderSide(color: t.borderDefault);
          }),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: FitCoreSpace.x4,
              vertical: FitCoreSpace.x3,
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FitCoreRadius.md),
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(t.accent),
          overlayColor: WidgetStatePropertyAll(t.rowHover),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: FitCoreSpace.x3),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FitCoreRadius.sm),
            ),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(t.textSecondary),
          overlayColor: WidgetStatePropertyAll(t.rowHover),
          minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FitCoreRadius.sm),
            ),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: t.textSecondary, size: 18),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(t.elevated),
        headingRowHeight: 40,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 56,
        horizontalMargin: FitCoreSpace.x4,
        columnSpacing: FitCoreSpace.x6,
        dividerThickness: 1,
        headingTextStyle: textTheme.labelSmall?.copyWith(
          color: t.textMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        dataTextStyle: textTheme.bodyMedium,
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return t.rowHover;
          return Colors.transparent;
        }),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(t.elevated),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FitCoreRadius.md),
              side: BorderSide(color: t.borderDefault),
            ),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.elevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoreRadius.md),
          side: BorderSide(color: t.borderDefault),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(t.elevated),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FitCoreRadius.md),
              side: BorderSide(color: t.borderDefault),
            ),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.accent,
        linearTrackColor: t.elevated,
        circularTrackColor: t.elevated,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.elevated,
        side: BorderSide(color: t.borderDefault),
        labelStyle: textTheme.labelSmall?.copyWith(color: t.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoreRadius.sm),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.textSecondary,
        textColor: t.textPrimary,
        minVerticalPadding: FitCoreSpace.x2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FitCoreRadius.md),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(t.borderDefault),
        radius: const Radius.circular(FitCoreRadius.xs),
        thickness: const WidgetStatePropertyAll(8),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(FitCoreRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(TextTheme base, FitCoreTokens t) {
    final body = GoogleFonts.plusJakartaSansTextTheme(base);

    TextStyle style(
      double size,
      FontWeight weight,
      Color color, {
      double spacing = 0,
      double height = 1.4,
    }) {
      return GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height,
      );
    }

    return body.copyWith(
      displaySmall: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: t.textPrimary,
        letterSpacing: -0.8,
      ),
      headlineSmall: style(26, FontWeight.w700, t.textPrimary, spacing: -0.5),
      titleLarge: style(22, FontWeight.w700, t.textPrimary, spacing: -0.4),
      titleMedium: style(16, FontWeight.w700, t.textPrimary, spacing: -0.1),
      titleSmall: style(14, FontWeight.w600, t.textPrimary),
      bodyLarge: style(15, FontWeight.w400, t.textPrimary, height: 1.45),
      bodyMedium: style(14, FontWeight.w400, t.textPrimary, height: 1.45),
      bodySmall: style(13, FontWeight.w400, t.textSecondary, height: 1.4),
      labelLarge: style(14, FontWeight.w600, t.textPrimary),
      labelMedium: style(13, FontWeight.w500, t.textSecondary, spacing: 0.1),
      labelSmall: style(12, FontWeight.w500, t.textMuted, spacing: 0.2),
    );
  }
}
