import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_action_notifier.dart';

final attendanceActionProvider =
    AsyncNotifierProvider<AttendanceActionNotifier, void>(
      AttendanceActionNotifier.new,
    );
