import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared chrome for the sign-in surfaces: brand mark, portal label, and a
/// bordered card holding whatever fields the page already owns.
class FitAuthScaffold extends StatelessWidget {
  const FitAuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.brandName = 'FitCore',
  });

  final String brandName;

  /// Heading inside the card, e.g. the portal or the task.
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Scaffold(
      backgroundColor: t.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: FitCoreSpace.x6,
              vertical: FitCoreSpace.x8,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: t.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(FitCoreRadius.sm),
                          border: Border.all(
                            color: t.accent.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Text(
                          brandName.isEmpty ? 'F' : brandName[0].toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: t.accent,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: FitCoreSpace.x2),
                      Text(
                        brandName,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: t.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FitCoreSpace.x6),
                  Container(
                    padding: const EdgeInsets.all(FitCoreSpace.x6),
                    decoration: BoxDecoration(
                      color: t.panel,
                      borderRadius: BorderRadius.circular(FitCoreRadius.xl),
                      border: Border.all(color: t.borderDefault),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: FitCoreSpace.x1),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: t.textSecondary,
                          ),
                        ),
                        const SizedBox(height: FitCoreSpace.x6),
                        child,
                      ],
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

/// Primary submit button for auth forms, with an inline progress state.
class FitAuthSubmitButton extends StatelessWidget {
  const FitAuthSubmitButton({
    super.key,
    required this.label,
    required this.isSubmitting,
    required this.onPressed,
  });

  final String label;
  final bool isSubmitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isSubmitting ? null : onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
      child: isSubmitting
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
