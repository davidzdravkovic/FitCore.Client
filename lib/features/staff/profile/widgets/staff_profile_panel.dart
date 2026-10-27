import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/routing/staff_paths.dart';
import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/features/staff/auth/staff_session.dart';
import 'package:fitcore_client/features/staff/schedule/api/staff_me_api.dart';
import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffProfilePanel extends StatefulWidget {
  const StaffProfilePanel({super.key, this.staffMeApi});

  final StaffMeApi? staffMeApi;

  @override
  State<StaffProfilePanel> createState() => _StaffProfilePanelState();
}

class _StaffProfilePanelState extends State<StaffProfilePanel> {
  late final StaffMeApi _api = widget.staffMeApi ?? StaffMeApi();
  StaffResponse? _me;
  bool _loading = true;
  String? _error;
  int _epoch = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final gen = ++_epoch;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final me = await _api.get();
      if (gen != _epoch || !mounted) return;
      setState(() {
        _me = me;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (gen != _epoch || !mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _signOut() {
    ApiClient.instance.setAccessToken(null);
    StaffSession.clear();
    context.go(StaffPaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final phone =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;
    final pad = phone ? FitCoreSpace.x3 : DashboardLayout.pagePadding;

    if (_loading && _me == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _me == null) {
      return FitErrorState(message: _error!, onRetry: _load);
    }

    final me = _me;
    if (me == null) {
      return const Center(child: Text('Could not load your profile.'));
    }

    final name = '${me.firstName} ${me.lastName}'.trim();

    return ListView(
      padding: EdgeInsets.all(pad),
      children: [
        Text(
          'Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FitCoreSpace.x4),
        Container(
          padding: const EdgeInsets.all(FitCoreSpace.x4),
          decoration: BoxDecoration(
            color: t.panel,
            borderRadius: BorderRadius.circular(FitCoreRadius.lg),
            border: Border.all(color: t.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                name.isEmpty ? 'Coach' : name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FitCoreSpace.x3),
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 18, color: t.textSecondary),
                  const SizedBox(width: FitCoreSpace.x2),
                  Expanded(
                    child: Text(
                      me.email.isNotEmpty ? me.email : 'No email',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (phone) ...[
          const SizedBox(height: FitCoreSpace.x5),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign out'),
          ),
        ],
      ],
    );
  }
}
