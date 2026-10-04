import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';

import 'attendance_test_data.dart';
import 'authorization_test_data.dart';

final DateTime payrollTestMonth = DateTime(2026, 9);

List<Override> payrollDataOverrides({Override? authorization}) {
  return [
    authorization ??
        fullAccessAuthorizationOverride(employeeId: testEmployeeId),
    employeeRepositoryProvider.overrideWithValue(FakeEmployeeRepository()),
    attendanceRepositoryProvider.overrideWithValue(
      FakeAttendanceRepository([
        buildAttendance(
          id: 'att-1',
          date: DateTime(2026, 9, 27),
          checkIn: DateTime(2026, 9, 27, 8),
          checkOut: DateTime(2026, 9, 27, 17),
        ),
      ]),
    ),
    departmentRepositoryProvider.overrideWithValue(FakeDepartmentRepository()),
    generalSettingsRepositoryProvider.overrideWithValue(
      FakeGeneralSettingsRepository(),
    ),
    officialHolidayRepositoryProvider.overrideWithValue(
      FakeOfficialHolidayRepository(),
    ),
    currentPayrollMonthProvider.overrideWith((ref) => payrollTestMonth),
    selectedPayrollMonthProvider.overrideWith((ref) => payrollTestMonth),
  ];
}

Future<ProviderContainer> createPayrollTestContainer({
  List<Override> extraOverrides = const [],
}) async {
  final container = ProviderContainer(
    overrides: [...payrollDataOverrides(), ...extraOverrides],
  );

  addTearDown(container.dispose);

  await container.read(authorizationProvider.future);
  await container.read(employeeProvider.notifier).getEmployees();
  await container.read(attendanceProvider.notifier).getAttendances();
  await container.read(departmentProvider.notifier).getDepartments();
  await container.read(generalSettingsProvider.future);
  await container.read(officialHolidaysProvider.notifier).getOfficialHolidays();

  return container;
}
