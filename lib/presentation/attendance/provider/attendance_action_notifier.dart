import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_action_result.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/today_attendance_provider.dart';

class AttendanceActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<AttendanceActionResult> checkIn(
    String employeeId, {
    DateTime? now,
  }) async {
    state = const AsyncLoading();

    final moment = now ?? DateTime.now();

    final performed = await AsyncValue.guard<AttendanceActionResult>(() async {
      final existing = await ref
          .read(getAttendanceByEmployeeAndDateUseCaseProvider)
          .call(employeeId, moment);

      if (existing == null) {
        await ref
            .read(addAttendanceUseCaseProvider)
            .call(
              AttendanceEntity(
                id: AttendanceEntity.documentIdFor(employeeId, moment),
                employeeId: employeeId,
                attendanceDate: _dateOnly(moment),
                status: AttendanceEntity.presentStatus,
                checkInTime: moment,
              ),
            );

        return AttendanceActionResult.success;
      }

      if (existing.checkInTime != null) {
        return AttendanceActionResult.alreadyCheckedIn;
      }

      await ref
          .read(updateAttendanceUseCaseProvider)
          .call(
            AttendanceEntity(
              id: existing.id,
              employeeId: existing.employeeId,
              attendanceDate: existing.attendanceDate,
              status: existing.status,
              checkInTime: moment,
              checkOutTime: existing.checkOutTime,
            ),
          );

      return AttendanceActionResult.success;
    });

    if (performed.hasError) {
      state = AsyncError(
        performed.error!,
        performed.stackTrace ?? StackTrace.current,
      );

      return AttendanceActionResult.failure;
    }

    state = const AsyncData(null);

    final result = performed.value ?? AttendanceActionResult.failure;

    if (result == AttendanceActionResult.success) {
      await _refresh();
    }

    return result;
  }

  Future<AttendanceActionResult> checkOut(
    String employeeId, {
    DateTime? now,
  }) async {
    state = const AsyncLoading();

    final moment = now ?? DateTime.now();

    final performed = await AsyncValue.guard<AttendanceActionResult>(() async {
      final existing = await ref
          .read(getAttendanceByEmployeeAndDateUseCaseProvider)
          .call(employeeId, moment);

      if (existing == null || existing.checkInTime == null) {
        return AttendanceActionResult.checkInRequired;
      }

      if (existing.checkOutTime != null) {
        return AttendanceActionResult.alreadyCheckedOut;
      }

      await ref
          .read(updateAttendanceUseCaseProvider)
          .call(
            AttendanceEntity(
              id: existing.id,
              employeeId: existing.employeeId,
              attendanceDate: existing.attendanceDate,
              status: existing.status,
              checkInTime: existing.checkInTime,
              checkOutTime: moment,
            ),
          );

      return AttendanceActionResult.success;
    });

    if (performed.hasError) {
      state = AsyncError(
        performed.error!,
        performed.stackTrace ?? StackTrace.current,
      );

      return AttendanceActionResult.failure;
    }

    state = const AsyncData(null);

    final result = performed.value ?? AttendanceActionResult.failure;

    if (result == AttendanceActionResult.success) {
      await _refresh();
    }

    return result;
  }

  Future<void> _refresh() async {
    ref.invalidate(todayAttendanceProvider);

    await ref.read(attendanceProvider.notifier).getAttendances();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
