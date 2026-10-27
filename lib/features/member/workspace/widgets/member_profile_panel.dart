import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/routing/member_paths.dart';
import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/features/member/auth/member_session.dart';
import 'package:fitcore_client/features/member/workspace/member_home_controller.dart';
import 'package:fitcore_client/features/member/workspace/widgets/member_profile_card.dart';
import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemberProfilePanel extends StatefulWidget {
  const MemberProfilePanel({super.key, this.controller});

  final MemberHomeController? controller;

  @override
  State<MemberProfilePanel> createState() => _MemberProfilePanelState();
}

class _MemberProfilePanelState extends State<MemberProfilePanel> {
  late final MemberHomeController _controller =
      widget.controller ?? MemberHomeController();
  late final bool _ownsController = widget.controller == null;

  @override
  void initState() {
    super.initState();
    if (_controller.profile == null) {
      _controller.load();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _signOut() {
    ApiClient.instance.setAccessToken(null);
    MemberSession.clear();
    context.go(MemberPaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final phone =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;
    final pad = phone ? FitCoreSpace.x3 : DashboardLayout.pagePadding;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading && _controller.profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.error != null && _controller.profile == null) {
          return FitErrorState(
            message: _controller.error!,
            onRetry: _controller.load,
          );
        }

        final profile = _controller.profile;
        if (profile == null) {
          return const Center(child: Text('Could not load your profile.'));
        }

        return ListView(
          padding: EdgeInsets.all(pad),
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: FitCoreSpace.x4),
            MemberProfileCard(profile: profile),
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
      },
    );
  }
}
