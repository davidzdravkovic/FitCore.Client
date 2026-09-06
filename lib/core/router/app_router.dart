import 'package:fitcore_client/features/platform_auth/platform_login_page.dart';
import 'package:fitcore_client/features/platform_auth/platform_verify_page.dart';
import 'package:fitcore_client/features/platform_dashboard/platform_dashboard_page.dart';
import 'package:fitcore_client/features/tenant_dashboard/tenant_dashboard_page.dart';
import 'package:fitcore_client/features/tenant_registry/tenant_registry_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/platform/login',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/platform/login',
    ),
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
    GoRoute(
      path: '/tenant/registry',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        return TenantRegistryPage(token: token);
      },
    ),
    GoRoute(
      path: '/tenant',
      builder: (context, state) => const TenantDashboardPage(),
    ),
  ],
);
