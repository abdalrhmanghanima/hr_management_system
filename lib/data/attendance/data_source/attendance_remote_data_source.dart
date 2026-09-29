import 'package:hr_management_system/data/attendance/model/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceModel>> getAttendances();

  Future<List<AttendanceModel>> getAttendancesByEmployeeId(String employeeId);

  Future<AttendanceModel?> getAttendanceByEmployeeAndDate(
    String employeeId,
    DateTime date,
  );

  Future<void> addAttendance(AttendanceModel attendance);

  Future<void> updateAttendance(AttendanceModel attendance);

  Future<void> deleteAttendance(String id);
}
