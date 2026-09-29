class AttendanceImportException implements Exception {
  final String message;

  const AttendanceImportException(this.message);

  @override
  String toString() {
    return message;
  }
}
