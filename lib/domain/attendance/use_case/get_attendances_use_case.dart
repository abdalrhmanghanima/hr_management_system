import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';

class GetAttendancesUseCase {
  final AttendanceRepository repository;

  GetAttendancesUseCase(this.repository);

  Future<List<AttendanceEntity>> call() {
    return repository.getAttendances();
  }
}
