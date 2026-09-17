final class Validators {

  static String? fullName(String? value) {
    final String name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Full name is required';
    }

    if (name.length < 3) {
      return 'Name must be at least 3 characters';
    }

    if (!RegExp(
      r'^[a-zA-Z\s]+$',
    ).hasMatch(name)) {
      return 'Enter a valid name';
    }

    return null;
  }


  static String? phone(String? value) {
    final String phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Phone number is required';
    }

    if (!RegExp(
      r'^[0-9+\-\s]{9,15}$',
    ).hasMatch(phone)) {
      return 'Enter a valid phone number';
    }

    return null;
  }


  static String? email(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email)) {
      return 'Enter a valid email';
    }

    return null;
  }


  static String? password(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be minimum 6 characters';
    }

    return null;
  }
}