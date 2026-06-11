abstract final class FormValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
      return 'Password must contain lowercase letters';
    }
    if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain uppercase letters';
    }
    if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
      return 'Password must contain digits';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    return null;
  }

  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.length > 100) {
      return 'Title must not exceed 100 characters';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'Description must not exceed 500 characters';
    }
    return null;
  }

  static String? validateGroupCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Group code is required';
    }
    if (value.length != 6) {
      return 'Group code must be 6 characters';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
