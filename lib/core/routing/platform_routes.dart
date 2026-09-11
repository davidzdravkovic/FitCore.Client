import 'package:fitcore_client/features/platform/auth/login/platform_login_page.dart';
import 'package:fitcore_client/features/platform/auth/verify/platform_verify_page.dart';
import 'package:fitcore_client/features/platform/dashboard/platform_dashboard_page.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> platformRoutes = [
  GoRoute(
    path: '/platform/login',
    builder: (context, state) => const PlatformLoginPage(),
  ),
  GoRoute(
    path: '/platform/verify',
    builder: (context, state) {
      final token = state.uri.queryParameters['token'];
      return PlatformVerifyPage(token: token);
    },
  ),
  GoRoute(
    path: '/platform',
    builder: (context, state) => const PlatformDashboardPage(),
  ),
];
