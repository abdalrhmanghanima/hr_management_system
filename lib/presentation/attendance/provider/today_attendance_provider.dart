import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';

final todayAttendanceProvider = FutureProvider.autoDispose
    .family<AttendanceEntity?, ({String employeeId, DateTime date})>((
      ref,
      key,
    ) {
      return ref
          .read(getAttendanceByEmployeeAndDateUseCaseProvider)
          .call(key.employeeId, key.date);
    });

DateTime todayKey() {
  final now = DateTime.now();

  return DateTime(now.year, now.month, now.day);
}
