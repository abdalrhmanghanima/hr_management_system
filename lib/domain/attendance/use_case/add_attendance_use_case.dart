import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';

class AddAttendanceUseCase {
  final AttendanceRepository repository;

  AddAttendanceUseCase(this.repository);

  Future<void> call(AttendanceEntity attendance) {
    return repository.addAttendance(attendance);
  }
}
