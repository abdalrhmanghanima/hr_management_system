import 'package:hr_management_system/data/attendance/data_source/attendance_remote_data_source.dart';
import 'package:hr_management_system/data/attendance/model/attendance_model.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/attendance/repository/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AttendanceEntity>> getAttendances() async {
    final attendances = await remoteDataSource.getAttendances();

    return attendances.map((attendance) {
      return attendance.toEntity();
    }).toList();
  }

  @override
  Future<List<AttendanceEntity>> getAttendancesByEmployeeId(
    String employeeId,
  ) async {
    final attendances = await remoteDataSource.getAttendancesByEmployeeId(
      employeeId,
    );

    return attendances.map((attendance) {
      return attendance.toEntity();
    }).toList();
  }

  @override
  Future<AttendanceEntity?> getAttendanceByEmployeeAndDate(
    String employeeId,
    DateTime date,
  ) async {
    final attendance = await remoteDataSource.getAttendanceByEmployeeAndDate(
      employeeId,
      date,
    );

    return attendance?.toEntity();
  }

  @override
  Future<void> addAttendance(AttendanceEntity attendance) async {
    final model = AttendanceModel(
      id: attendance.id,
      employeeId: attendance.employeeId,
      attendanceDate: attendance.attendanceDate,
      status: attendance.status,
      checkInTime: attendance.checkInTime,
      checkOutTime: attendance.checkOutTime,
    );

    await remoteDataSource.addAttendance(model);
  }

  @override
  Future<void> updateAttendance(AttendanceEntity attendance) async {
    final model = AttendanceModel(
      id: attendance.id,
      employeeId: attendance.employeeId,
      attendanceDate: attendance.attendanceDate,
      status: attendance.status,
      checkInTime: attendance.checkInTime,
      checkOutTime: attendance.checkOutTime,
    );

    await remoteDataSource.updateAttendance(model);
  }

  @override
  Future<void> deleteAttendance(String id) async {
    await remoteDataSource.deleteAttendance(id);
  }
}
