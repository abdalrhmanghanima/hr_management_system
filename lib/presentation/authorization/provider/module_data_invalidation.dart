import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_attendance_status_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_employee_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/today_attendance_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_by_id_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_details_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/gender_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/selected_department_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';

void invalidateModuleData(WidgetRef ref) {
  ref
    ..invalidate(employeeProvider)
    ..invalidate(employeeDetailsProvider)
    ..invalidate(departmentProvider)
    ..invalidate(departmentByIdProvider)
    ..invalidate(attendanceProvider)
    ..invalidate(todayAttendanceProvider)
    ..invalidate(selectedEmployeeProvider)
    ..invalidate(selectedAttendanceStatusProvider)
    ..invalidate(officialHolidaysProvider)
    ..invalidate(payrollSummariesProvider)
    ..invalidate(genderProvider)
    ..invalidate(selectedDepartmentProvider);
}

Future<void> reloadModuleData(WidgetRef ref) async {
  invalidateModuleData(ref);

  await Future.wait([
    ref.read(employeeProvider.notifier).getEmployees(),
    ref.read(departmentProvider.notifier).getDepartments(),
    ref.read(attendanceProvider.notifier).getAttendances(),
    ref.read(officialHolidaysProvider.notifier).getOfficialHolidays(),
  ]);
}
