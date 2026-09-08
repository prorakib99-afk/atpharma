abstract final class EmailValidation {
  static String? validate(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Enter your registered email';
    if (email.length > 254 ||
        !RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?)+$",
        ).hasMatch(email)) {
      return 'Enter a valid email address';
    }
    final local = email.split('@').first;
    final domain = email.split('@').last;
    if (local.length > 64 ||
        local.startsWith('.') ||
        local.endsWith('.') ||
        local.contains('..') ||
        domain.split('.').any((part) => part.length > 63)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
