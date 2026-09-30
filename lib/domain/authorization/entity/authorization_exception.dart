class AuthorizationException implements Exception {
  final String message;

  const AuthorizationException(this.message);

  @override
  String toString() => message;
}
