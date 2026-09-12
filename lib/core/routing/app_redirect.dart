import 'package:fitcore_client/core/auth/auth_session.dart';
import 'package:fitcore_client/core/routing/member_paths.dart';
import 'package:fitcore_client/core/routing/platform_paths.dart';
import 'package:fitcore_client/core/routing/staff_paths.dart';
import 'package:fitcore_client/core/routing/tenant_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

String? appRedirect(BuildContext context, GoRouterState state) {
  final path = state.uri.path;

  if (PlatformPaths.matches(path)) {
    if (!PlatformPaths.isAuthRoute(path) && !AuthSession.isPlatformAdmin) {
      return PlatformPaths.login;
    }
  }

  if (TenantPaths.matches(path)) {
    if (!TenantPaths.isAuthRoute(path) && !AuthSession.isTenantOwner) {
      return TenantPaths.login;
    }
  }

  if (StaffPaths.matches(path)) {
    if (!StaffPaths.isAuthRoute(path) && !AuthSession.isTenantStaff) {
      return StaffPaths.login;
    }
  }

  if (MemberPaths.matches(path)) {
    if (!MemberPaths.isAuthRoute(path) && !AuthSession.isMember) {
      return MemberPaths.login;
    }
  }

  return null;
}
