import 'package:fitcore_client/features/tenant/auth/registry/widgets/registry_atmosphere.dart';
import 'package:flutter/material.dart';

/// Owns registry enter + ambient animations and wraps [child].
class RegistryMotionShell extends StatefulWidget {
  const RegistryMotionShell({super.key, required this.child});

  final Widget child;

  @override
  State<RegistryMotionShell> createState() => _RegistryMotionShellState();
}

class _RegistryMotionShellState extends State<RegistryMotionShell>
    with TickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final AnimationController _enterController;
  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;
  late final CurvedAnimation _enterCurve;

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
    _enterCurve = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    );
    _enterFade = _enterCurve;
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(_enterCurve);
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterCurve.dispose();
    _ambientController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
