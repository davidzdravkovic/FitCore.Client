import 'package:fitcore_client/core/auth/auth_session.dart';
import 'package:fitcore_client/features/member/auth/activate/member_activate_page.dart';
import 'package:fitcore_client/features/member/auth/login/member_login_page.dart';
import 'package:fitcore_client/features/member/workspace/member_dashboard_page.dart';
import 'package:fitcore_client/features/platform/auth/login/platform_login_page.dart';
import 'package:fitcore_client/features/platform/auth/verify/platform_verify_page.dart';
import 'package:fitcore_client/features/platform/dashboard/platform_dashboard_page.dart';
import 'package:fitcore_client/features/staff/auth/activate/staff_activate_page.dart';
import 'package:fitcore_client/features/staff/auth/login/staff_login_page.dart';
import 'package:fitcore_client/features/staff/workspace/staff_dashboard_page.dart';
import 'package:fitcore_client/features/tenant/dashboard/tenant_dashboard_page.dart';
import 'package:fitcore_client/features/tenant/auth/registry/tenant_registry_page.dart';
import 'package:fitcore_client/features/tenant/auth/login/tenant_login_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/platform/login',
  redirect: (context, state) {
    final path = state.uri.path;

    if (path == '/platform') {
      if (!AuthSession.isPlatformAdmin) return '/platform/login';
      return null;
    }

    if (path == '/tenant') {
      if (!AuthSession.isTenantOwner) return '/tenant/login';
      return null;
    }

    if (path == '/staff') {
      if (!AuthSession.isTenantStaff) return '/staff/login';
      return null;
    }

    if (path == '/member') {
      if (!AuthSession.isMember) return '/member/login';
      return null;
    }

    return null;
  },
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
      path: '/tenant/login',
      builder: (context, state) => const TenantLoginPage(),
    ),
    GoRoute(
      path: '/tenant',
      builder: (context, state) => const TenantDashboardPage(),
    ),
    GoRoute(
      path: '/staff/login',
      builder: (context, state) => const StaffLoginPage(),
    ),
    GoRoute(
      path: '/staff/activate',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        return StaffActivatePage(token: token);
      },
    ),
    GoRoute(
      path: '/staff',
      builder: (context, state) => const StaffDashboardPage(),
    ),
    GoRoute(
      path: '/member/login',
      builder: (context, state) => const MemberLoginPage(),
    ),
    GoRoute(
      path: '/member/activate',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        return MemberActivatePage(token: token);
      },
    ),
    GoRoute(
      path: '/member',
      builder: (context, state) => const MemberDashboardPage(),
    ),
  ],
);
