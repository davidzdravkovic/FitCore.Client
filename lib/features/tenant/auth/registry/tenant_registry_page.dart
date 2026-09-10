import 'package:fitcore_client/features/tenant/auth/registry/widgets/registry_brand_panel.dart';
import 'package:fitcore_client/features/tenant/auth/registry/widgets/registry_form.dart';
import 'package:fitcore_client/features/tenant/auth/registry/widgets/registry_motion_shell.dart';
import 'package:flutter/material.dart';

class TenantRegistryPage extends StatelessWidget {
  const TenantRegistryPage({super.key, this.token});

  final String? token;

  @override
  Widget build(BuildContext context) {
    final hasToken = token != null && token!.isNotEmpty;
    final wide = MediaQuery.sizeOf(context).width >= 960;

    return RegistryMotionShell(
      child: wide
          ? Row(
              children: [
                Expanded(
                  flex: 5,
                  child: RegistryBrandPanel(hasToken: hasToken),
                ),
                Expanded(
                  flex: 6,
                  child: Align(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 48,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: RegistryForm(invitationToken: token),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RegistryBrandPanel(
                        hasToken: hasToken,
                        compact: true,
                      ),
                      const SizedBox(height: 28),
                      RegistryForm(invitationToken: token),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
