import 'package:lms/core/constants/app_constants.dart';

/// Normalizes avatar locations returned by the API into absolute URLs.
class AvatarUrl {
  AvatarUrl._();

  /// Turns an avatar value from the API into an absolute URL.
  ///
  /// The backend sometimes returns a bare relative path (e.g. `/uploads/...`)
  /// or the literal placeholder `undefined/uploads/...` when it fails to render
  /// its own base URL. Both are resolved against [AppConstants.baseDomain].
  /// Already-absolute URLs are returned untouched. Returns `null` when [raw] is
  /// missing or blank so callers can render a placeholder instead.
  static String? resolve(String? raw) {
    if (raw == null) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    // Strip the "undefined/" placeholder the backend emits when it fails to
    // render the base URL. The server serves uploaded files under `/uploads`.
    if (value.startsWith('undefined/')) {
      value = value.substring('undefined/'.length);
    }
    final path = value.startsWith('/') ? value : '/$value';
    const domain = AppConstants.baseDomain;
    final base =
        domain.endsWith('/') ? domain.substring(0, domain.length - 1) : domain;
    return '$base$path';
  }
}
