import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/today_attendance_provider.dart';

class AttendanceNotifier extends AsyncNotifier<List<AttendanceEntity>> {
  @override
  Future<List<AttendanceEntity>> build() async {
    return [];
  }

  Future<void> getAttendances() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getAttendancesUseCaseProvider).call(),
    );
  }

  Future<SaveResult> addAttendance(AttendanceEntity attendance) async {
    try {
      final existing = await ref
          .read(getAttendanceByEmployeeAndDateUseCaseProvider)
          .call(attendance.employeeId, attendance.attendanceDate);

      if (existing != null) {
        return SaveResult.duplicate;
      }

      state = const AsyncLoading();

      await ref.read(addAttendanceUseCaseProvider).call(attendance);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return SaveResult.failure;
    }

    ref.invalidate(todayAttendanceProvider);

    await getAttendances();

    return SaveResult.success;
  }

  Future<void> updateAttendance(AttendanceEntity attendance) async {
    await ref.read(updateAttendanceUseCaseProvider).call(attendance);
    await getAttendances();
  }

  Future<void> deleteAttendance(String id) async {
    await ref.read(deleteAttendanceUseCaseProvider).call(id);
    await getAttendances();
  }

  Future<void> getAttendancesByEmployeeId(String employeeId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () =>
          ref.read(getAttendancesByEmployeeIdUseCaseProvider).call(employeeId),
    );
  }
}
