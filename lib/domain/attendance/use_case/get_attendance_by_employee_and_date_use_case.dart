import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';

class GetAttendanceByEmployeeAndDateUseCase {
  final AttendanceRepository repository;

  GetAttendanceByEmployeeAndDateUseCase(this.repository);

  Future<AttendanceEntity?> call(String employeeId, DateTime date) {
    return repository.getAttendanceByEmployeeAndDate(employeeId, date);
  }
}
