/// Route path catalog for the member portal (keep with member when splitting apps).
abstract final class MemberPaths {
  static const root = '/member';
  static const login = '/member/login';
  static const activate = '/member/activate';
  static const home = '/member';

  static bool matches(String path) =>
      path == root || path.startsWith('$root/');

  static bool isAuthRoute(String path) => path == login || path == activate;
}
