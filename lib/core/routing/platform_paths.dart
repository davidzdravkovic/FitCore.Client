/// Route path catalog for the platform portal (keep with platform when splitting apps).
abstract final class PlatformPaths {
  static const root = '/platform';
  static const login = '/platform/login';
  static const verify = '/platform/verify';
  static const home = '/platform';

  static bool matches(String path) =>
      path == root || path.startsWith('$root/');

  static bool isAuthRoute(String path) => path == login || path == verify;
}
