import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAttendances();

  Future<List<AttendanceEntity>> getAttendancesByEmployeeId(String employeeId);

  Future<AttendanceEntity?> getAttendanceByEmployeeAndDate(
    String employeeId,
    DateTime date,
  );

  Future<void> addAttendance(AttendanceEntity attendance);

  Future<void> updateAttendance(AttendanceEntity attendance);

  Future<void> deleteAttendance(String id);
}
