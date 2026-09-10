class Validators {
  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email';
    }

    return null;
  }

  static String? optionalEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email';
    }

    return null;
  }

  static String? optionalPhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;

    if (phone.length < 7) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  /// At least one of email or phone must be present (after trim).
  static String? emailOrPhone({String? email, String? phone}) {
    final e = email?.trim() ?? '';
    final p = phone?.trim() ?? '';
    if (e.isEmpty && p.isEmpty) {
      return 'Provide an email or phone number';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'At least 8 characters';
    }

    return null;
  }
}
