import 'package:fitcore_client/features/tenant_registry/widgets/registry_atmosphere.dart';
import 'package:fitcore_client/features/tenant_registry/widgets/registry_brand_panel.dart';
import 'package:fitcore_client/features/tenant_registry/widgets/registry_form.dart';
import 'package:flutter/material.dart';

class TenantRegistryPage extends StatefulWidget {
  const TenantRegistryPage({super.key, this.token});

  final String? token;

  @override
  State<TenantRegistryPage> createState() => _TenantRegistryPageState();
}

class _TenantRegistryPageState extends State<TenantRegistryPage>
    with TickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final AnimationController _enterController;
  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _enterFade = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    );
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );
    _enterController.forward();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasToken = widget.token != null && widget.token!.isNotEmpty;
    final wide = MediaQuery.sizeOf(context).width >= 960;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          RegistryAtmosphere(animation: _ambientController),
          SafeArea(
            child: FadeTransition(
              opacity: _enterFade,
              child: SlideTransition(
                position: _enterSlide,
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
                                  constraints: const BoxConstraints(
                                    maxWidth: 460,
                                  ),
                                  child: RegistryForm(
                                    invitationToken: widget.token,
                                  ),
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
                                RegistryForm(invitationToken: widget.token),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
