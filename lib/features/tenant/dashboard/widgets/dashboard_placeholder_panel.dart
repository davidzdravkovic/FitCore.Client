import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:flutter/material.dart';

class DashboardPlaceholderPanel extends StatelessWidget {
  const DashboardPlaceholderPanel({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.construction_outlined,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FitEmptyState(icon: icon, title: title, message: description);
  }
}
