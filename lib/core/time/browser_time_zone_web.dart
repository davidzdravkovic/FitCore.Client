import 'dart:js_interop';

String? browserTimeZone() {
  try {
    final options = DateTimeFormat().resolvedOptions();
    final zone = options.timeZone;
    return zone.isEmpty ? null : zone;
  } catch (_) {
    return null;
  }
}

@JS('Intl.DateTimeFormat')
extension type DateTimeFormat._(JSObject _) implements JSObject {
  external factory DateTimeFormat();
  external ResolvedOptions resolvedOptions();
}

extension type ResolvedOptions._(JSObject _) implements JSObject {
  external String get timeZone;
}
