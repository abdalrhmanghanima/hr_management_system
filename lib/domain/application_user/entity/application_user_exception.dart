class ApplicationUserException implements Exception {
  final String messageKey;

  const ApplicationUserException(this.messageKey);

  const ApplicationUserException.notLinked()
    : messageKey = 'auth.error_account_not_linked';

  const ApplicationUserException.inactive()
    : messageKey = 'auth.error_account_inactive';

  @override
  String toString() => messageKey;

  static String messageKeyOf(Object error) {
    if (error is ApplicationUserException) {
      return error.messageKey;
    }
    return 'auth.error_load_user';
  }
}
