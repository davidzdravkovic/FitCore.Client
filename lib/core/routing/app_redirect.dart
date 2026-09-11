import 'package:fitcore_client/core/auth/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

String? appRedirect(BuildContext context, GoRouterState state) {
  final path = state.uri.path;

  if (path.startsWith('/platform')) {
    final isAuthRoute =
        path == '/platform/login' || path == '/platform/verify';

    if (!isAuthRoute && !AuthSession.isPlatformAdmin) {
      return '/platform/login';
    }
  }

  if (path.startsWith('/tenant')) {
    final isAuthRoute =
        path == '/tenant/login' || path == '/tenant/registry';

    if (!isAuthRoute && !AuthSession.isTenantOwner) {
      return '/tenant/login';
    }
  }

  if (path.startsWith('/staff')) {
    final isAuthRoute =
        path == '/staff/login' || path == '/staff/activate';

    if (!isAuthRoute && !AuthSession.isTenantStaff) {
      return '/staff/login';
    }
  }

  if (path.startsWith('/member')) {
    final isAuthRoute =
        path == '/member/login' || path == '/member/activate';

    if (!isAuthRoute && !AuthSession.isMember) {
      return '/member/login';
    }
  }

  return null;
}
