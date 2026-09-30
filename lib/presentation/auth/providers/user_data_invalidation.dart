import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/utils/preferences.dart';
import 'package:hr_management_system/injection.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_action_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_attendance_status_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_employee_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/today_attendance_provider.dart';
import 'package:hr_management_system/presentation/auth/providers/login_provider.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_by_id_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_details_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/gender_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/selected_department_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void invalidateUserScopedData(Ref ref) {
  ref
    ..invalidate(loginProvider)
    ..invalidate(authorizationProvider)
    ..invalidate(employeeProvider)
    ..invalidate(employeeDetailsProvider)
    ..invalidate(departmentProvider)
    ..invalidate(departmentByIdProvider)
    ..invalidate(attendanceProvider)
    ..invalidate(attendanceActionProvider)
    ..invalidate(todayAttendanceProvider)
    ..invalidate(officialHolidaysProvider)
    ..invalidate(selectedEmployeeProvider)
    ..invalidate(selectedAttendanceStatusProvider)
    ..invalidate(genderProvider)
    ..invalidate(selectedDepartmentProvider)
    ..invalidate(payrollSummariesProvider);

  clearUserScopedStorage();
}

void clearUserScopedStorage() {
  if (getIt.isRegistered<SharedPreferences>()) {
    Preferences().logout();
  }
}
