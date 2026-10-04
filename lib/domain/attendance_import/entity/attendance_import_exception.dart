class AttendanceImportException implements Exception {
  final String message;

  final Map<String, String> namedArgs;

  const AttendanceImportException(this.message, {this.namedArgs = const {}});

  @override
  String toString() {
    return message;
  }
}
