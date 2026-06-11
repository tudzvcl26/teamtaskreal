abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  AppException(
    this.message, [
    this.stackTrace,
  ]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(
    super.message, [
    super.stackTrace,
  ]);
}

class AuthorizationException extends AppException {
  AuthorizationException(
    super.message, [
    super.stackTrace,
  ]);
}

class ValidationException extends AppException {
  ValidationException(
    super.message, [
    super.stackTrace,
  ]);
}

class NotFoundException extends AppException {
  NotFoundException(
    super.message, [
    super.stackTrace,
  ]);
}

class AuthenticationException extends AppException {
  AuthenticationException(
    super.message, [
    super.stackTrace,
  ]);
}

class UnknownException extends AppException {
  UnknownException(
    super.message, [
    super.stackTrace,
  ]);
}
