import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:flutter/material.dart';

/// Empty portal home used until staff/member features land.
class PortalPlaceholderDashboard extends StatelessWidget {
  const PortalPlaceholderDashboard({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
    required this.onSignOut,
    this.firstName,
  });

  final String title;
  final String? firstName;
  final String body;
  final IconData icon;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    final name = firstName?.trim();

    return Scaffold(
      backgroundColor: t.canvas,
      appBar: AppBar(
        backgroundColor: t.canvas,
        title: Text(title),
        shape: Border(bottom: BorderSide(color: t.borderSubtle)),
        actions: [
          TextButton(
            onPressed: onSignOut,
            style: TextButton.styleFrom(foregroundColor: t.textSecondary),
            child: const Text('Sign out'),
          ),
          const SizedBox(width: FitCoreSpace.x2),
        ],
      ),
      body: SafeArea(
        child: FitEmptyState(
          icon: icon,
          title: (name != null && name.isNotEmpty)
              ? 'Welcome, $name'
              : 'Welcome',
          message: body,
        ),
      ),
    );
  }
}
