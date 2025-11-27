class FormValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Az email megadása kötelező';
    }

    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Kérlek érvényes email címet adj meg';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kötelező jelszavat megadni';
    }

    if (value.length < 6) {
      return 'A jelszónak legalább 6 karakter hosszúnak kell lennie';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Kérlek erősítsd meg a jelszavad';
    }

    if (value != password) {
      return 'A jelszavak nem egyeznek';
    }

    return null;
  }

  static String formatAuthError(String error) {
    String coreError = _extractCoreErrorMessage(error);

    if (coreError.contains('Invalid login credentials') ||
        coreError.contains('invalid login credentials') ||
        coreError.contains('Invalid credentials')) {
      return 'Érvénytelen bejelentkezési adatok';
    } else if (coreError.contains('email address is already registered') ||
        coreError.contains('User already registered')) {
      return 'Ez az email cím már regisztrálva van. Kérlek használj másikat vagy jelentkezz be.';
    } else if (coreError.contains('invalid email') ||
        coreError.contains('Invalid email')) {
      return 'Kérlek érvényes email címet adj meg.';
    } else if (coreError.contains('password') &&
        (coreError.contains('weak') || coreError.contains('short'))) {
      return 'A jelszó túl gyenge. Kérlek használj erősebb jelszót.';
    } else if (coreError.contains('network') ||
        coreError.contains('Network') ||
        coreError.contains('connection')) {
      return 'Hálózati hiba. Ellenőrizd az internetkapcsolatot és próbáld újra.';
    }

    return coreError;
  }

  static String _extractCoreErrorMessage(String error) {
    String cleaned = error;

    if (cleaned.startsWith('Authentication error:')) {
      cleaned = cleaned.substring('Authentication error:'.length).trim();
    }

    if (cleaned.startsWith('Exception:')) {
      cleaned = cleaned.substring('Exception:'.length).trim();
    }

    if (cleaned.startsWith('Sign in failed:')) {
      cleaned = cleaned.substring('Sign in failed:'.length).trim();
    }
    if (cleaned.startsWith('Sign up failed:')) {
      cleaned = cleaned.substring('Sign up failed:'.length).trim();
    }

    final parts = cleaned.split(':');
    if (parts.length > 1) {
      cleaned = parts.last.trim();
    }

    return cleaned.isEmpty ? error : cleaned;
  }
}
