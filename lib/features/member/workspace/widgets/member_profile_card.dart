import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/widgets/fit_status_chip.dart';
import 'package:fitcore_client/features/member/workspace/models/member_profile_response.dart';
import 'package:flutter/material.dart';

class MemberProfileCard extends StatelessWidget {
  const MemberProfileCard({super.key, required this.profile});

  final MemberProfileResponse profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final member = profile.member;
    final name = '${member.firstName} ${member.lastName}'.trim();

    return Container(
      padding: const EdgeInsets.all(FitCoreSpace.x4),
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: BorderRadius.circular(FitCoreRadius.lg),
        border: Border.all(color: t.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name.isEmpty ? 'Member' : name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FitCoreSpace.x3),
          Row(
            children: [
              Icon(Icons.email_outlined, size: 18, color: t.textSecondary),
              const SizedBox(width: FitCoreSpace.x2),
              Expanded(
                child: Text(
                  member.email?.isNotEmpty == true ? member.email! : 'No email',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: FitCoreSpace.x2),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 18, color: t.textSecondary),
              const SizedBox(width: FitCoreSpace.x2),
              Expanded(
                child: Text(
                  member.phone?.isNotEmpty == true ? member.phone! : 'No phone',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (profile.memberships.isNotEmpty) ...[
            const SizedBox(height: FitCoreSpace.x4),
            Text(
              'Memberships',
              style: theme.textTheme.labelLarge?.copyWith(color: t.textMuted),
            ),
            const SizedBox(height: FitCoreSpace.x2),
            for (final membership in profile.memberships)
              Padding(
                padding: const EdgeInsets.only(bottom: FitCoreSpace.x3),
                child: Container(
                  padding: const EdgeInsets.all(FitCoreSpace.x3),
                  decoration: BoxDecoration(
                    color: t.elevated,
                    borderRadius: BorderRadius.circular(FitCoreRadius.md),
                    border: Border.all(color: t.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              membership.planName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          FitStatusChip(
                            label: membership.status,
                            tone: FitTone.muted,
                            dense: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: FitCoreSpace.x2),
                      Text(
                        '${membership.sessionsAvailable} available',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        '${membership.sessionsReserved} reserved · '
                        '${membership.sessionsBurned} used · '
                        '${membership.sessionTotal} total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
