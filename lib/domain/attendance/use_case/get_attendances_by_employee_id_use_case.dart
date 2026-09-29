import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';

class GetAttendancesByEmployeeIdUseCase {
  final AttendanceRepository repository;

  GetAttendancesByEmployeeIdUseCase(this.repository);

  Future<List<AttendanceEntity>> call(String employeeId) {
    return repository.getAttendancesByEmployeeId(employeeId);
  }
}
