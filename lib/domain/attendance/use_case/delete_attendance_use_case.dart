import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';

class DeleteAttendanceUseCase {
  final AttendanceRepository repository;

  DeleteAttendanceUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteAttendance(id);
  }
}
