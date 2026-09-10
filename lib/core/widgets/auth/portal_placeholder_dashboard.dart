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
    final theme = Theme.of(context);
    final name = firstName?.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: onSignOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  (name != null && name.isNotEmpty)
                      ? 'Welcome, $name'
                      : 'Welcome',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
