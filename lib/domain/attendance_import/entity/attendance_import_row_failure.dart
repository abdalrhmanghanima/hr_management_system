class AttendanceImportRowFailure implements Exception {
  final String reason;

  const AttendanceImportRowFailure(this.reason);

  @override
  String toString() {
    return reason;
  }
}
