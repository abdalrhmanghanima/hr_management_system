import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';

class UpdateAttendanceUseCase {
  final AttendanceRepository repository;

  UpdateAttendanceUseCase(this.repository);

  Future<void> call(AttendanceEntity attendance) {
    return repository.updateAttendance(attendance);
  }
}
