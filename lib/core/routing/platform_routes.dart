import 'package:fitcore_client/core/routing/platform_paths.dart';
import 'package:fitcore_client/features/platform/auth/login/platform_login_page.dart';
import 'package:fitcore_client/features/platform/auth/verify/platform_verify_page.dart';
import 'package:fitcore_client/features/platform/dashboard/platform_dashboard_page.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> platformRoutes = [
  GoRoute(
    path: PlatformPaths.login,
    builder: (context, state) => const PlatformLoginPage(),
  ),
  GoRoute(
    path: PlatformPaths.verify,
    builder: (context, state) {
      final token = state.uri.queryParameters['token'];
      return PlatformVerifyPage(token: token);
    },
  ),
  GoRoute(
    path: PlatformPaths.home,
    builder: (context, state) => const PlatformDashboardPage(),
  ),
];
