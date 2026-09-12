import 'package:fitcore_client/core/auth/auth_refresh.dart';
import 'package:fitcore_client/core/routing/app_redirect.dart';
import 'package:fitcore_client/core/routing/member_routes.dart';
import 'package:fitcore_client/core/routing/platform_paths.dart';
import 'package:fitcore_client/core/routing/platform_routes.dart';
import 'package:fitcore_client/core/routing/staff_routes.dart';
import 'package:fitcore_client/core/routing/tenant_routes.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: PlatformPaths.login,
  refreshListenable: AuthRefresh.instance,
  redirect: appRedirect,
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => PlatformPaths.login,
    ),
    ...platformRoutes,
    ...tenantRoutes,
    ...staffRoutes,
    ...memberRoutes,
  ],
);
