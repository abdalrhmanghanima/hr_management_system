class AttendanceEntity {
  static const String presentStatus = 'Present';

  final String id;
  final String employeeId;
  final DateTime attendanceDate;
  final String status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  const AttendanceEntity({
    required this.id,
    required this.employeeId,
    required this.attendanceDate,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
  });

  static String documentIdFor(String employeeId, DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return 'attendance_${employeeId}_${date.year}-$month-$day';
  }
}
