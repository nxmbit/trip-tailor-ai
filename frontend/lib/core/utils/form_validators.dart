//TODO: fix error messages (not loading from json file)

class Validators {
  static String? validateUsername(String? value, String missingValueMessage) {
    if (value == null || value.isEmpty) {
      return missingValueMessage;
    }
    return null;
  }

  static String? validateEmail(
    String? value,
    String missingValueMessage,
    String invalidValueMessage,
  ) {
    if (value == null || value.isEmpty) {
      return missingValueMessage;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return invalidValueMessage;
    }
    return null;
  }

  static String? validatePassword(
    String? value,
    String missingValueMessage,
    String invalidValueMessage,
  ) {
    if (value == null || value.isEmpty) {
      return missingValueMessage;
    }
    if (value.length < 6) {
      return invalidValueMessage;
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password,
    String missingValueMessage,
    String invalidValueMessage,
  ) {
    if (value == null || value.isEmpty) {
      return missingValueMessage;
    }
    if (value != password) {
      return invalidValueMessage;
    }
    return null;
  }
}
