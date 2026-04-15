class InputValidator {
  static String? validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateName(String value, {String label = 'Name'}) {
    if (value.trim().isEmpty) return '$label is required';
    if (value.trim().length < 2) return '$label is too short';
    if (value.trim().length > 100) return '$label is too long';
    return null;
  }

  /// Strips characters that could be used for SQL injection or XSS
  static String sanitizeSearch(String value) {
    // Removes common injection characters: < > " ' % ; ( ) & + \
    final sanitized = value.replaceAll(RegExp('[<>"\';%()&+]'), '').trim();
    if (sanitized.length > 100) return sanitized.substring(0, 100);
    return sanitized;
  }
}
