import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/today_attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/tab/attendance_tab.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/employee/tab/employee_tab.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/payroll/tab/payroll_tab.dart';

import '../../helpers/attendance_test_data.dart';

const Size testSurface = Size(400, 800);

void ignoreRenderFlexOverflows() {
  final previous = FlutterError.onError;

  FlutterError.onError = (details) {
    if (details.exceptionAsString().startsWith('A RenderFlex overflowed')) {
      return;
    }

    previous == null ? FlutterError.presentError(details) : previous(details);
  };

  addTearDown(() => FlutterError.onError = previous);
}

Future<void> pullToRefresh(WidgetTester tester, Finder scrollable) async {
  final gesture = await tester.startGesture(tester.getCenter(scrollable));

  for (var step = 0; step < 5; step++) {
    await gesture.moveBy(const Offset(0, 100));
    await tester.pump(const Duration(milliseconds: 50));
  }

  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home refresh reloads employees and attendances', (tester) async {
    ignoreRenderFlexOverflows();

    final employeeRepository = FakeEmployeeRepository();
    final attendanceRepository = FakeAttendanceRepository([
      buildAttendance(id: 'att-1'),
    ]);
    final generalSettingsRepository = FakeGeneralSettingsRepository();
    final officialHolidayRepository = FakeOfficialHolidayRepository();

    tester.view.physicalSize = testSurface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          attendanceRepositoryProvider.overrideWithValue(attendanceRepository),
          generalSettingsRepositoryProvider.overrideWithValue(
            generalSettingsRepository,
          ),
          officialHolidayRepositoryProvider.overrideWithValue(
            officialHolidayRepository,
          ),
        ],
        child: MaterialApp(navigatorKey: navigatorKey, home: const HomeTab()),
      ),
    );

    await tester.pumpAndSettle();

    expect(employeeRepository.loadCount, 1);
    expect(attendanceRepository.loadCount, 1);

    await pullToRefresh(tester, find.byType(SingleChildScrollView));

    expect(employeeRepository.loadCount, 2);
    expect(attendanceRepository.loadCount, 2);
  });

  testWidgets('employees refresh reloads employees and departments', (
    tester,
  ) async {
    final employeeRepository = FakeEmployeeRepository();
    final departmentRepository = FakeDepartmentRepository();

    tester.view.physicalSize = testSurface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          departmentRepositoryProvider.overrideWithValue(departmentRepository),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: const EmployeesTab(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final employeeLoadsBeforeRefresh = employeeRepository.loadCount;
    final departmentLoadsBeforeRefresh = departmentRepository.loadCount;

    await pullToRefresh(tester, find.byType(ListView));

    expect(employeeRepository.loadCount, employeeLoadsBeforeRefresh + 1);
    expect(departmentRepository.loadCount, departmentLoadsBeforeRefresh + 1);
  });

  testWidgets('attendance refresh reloads records and today attendance', (
    tester,
  ) async {
    final employeeRepository = FakeEmployeeRepository();
    final attendanceRepository = FakeAttendanceRepository([
      buildAttendance(id: 'att-1'),
    ]);
    final departmentRepository = FakeDepartmentRepository();

    tester.view.physicalSize = testSurface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        employeeRepositoryProvider.overrideWithValue(employeeRepository),
        attendanceRepositoryProvider.overrideWithValue(attendanceRepository),
        departmentRepositoryProvider.overrideWithValue(departmentRepository),
      ],
    );
    addTearDown(container.dispose);

    final todaySubscription = container.listen(
      todayAttendanceProvider((employeeId: testEmployeeId, date: todayKey())),
      (previous, next) {},
    );
    addTearDown(todaySubscription.close);

    await container.read(
      todayAttendanceProvider((
        employeeId: testEmployeeId,
        date: todayKey(),
      )).future,
    );

    await container.read(employeeProvider.notifier).getEmployees();
    await container.read(attendanceProvider.notifier).getAttendances();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: const AttendanceTab(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);

    final todayQueriesBeforeRefresh =
        attendanceRepository.byEmployeeAndDateCount;

    await pullToRefresh(tester, find.byType(ListView));

    expect(attendanceRepository.loadCount, 2);
    expect(employeeRepository.loadCount, 2);
    expect(
      attendanceRepository.byEmployeeAndDateCount,
      todayQueriesBeforeRefresh + 1,
    );
  });

  testWidgets('payroll refresh reloads employees and attendances', (
    tester,
  ) async {
    ignoreRenderFlexOverflows();

    final employeeRepository = FakeEmployeeRepository();
    final attendanceRepository = FakeAttendanceRepository();
    final departmentRepository = FakeDepartmentRepository();
    final generalSettingsRepository = FakeGeneralSettingsRepository();
    final officialHolidayRepository = FakeOfficialHolidayRepository();

    tester.view.physicalSize = testSurface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          attendanceRepositoryProvider.overrideWithValue(attendanceRepository),
          departmentRepositoryProvider.overrideWithValue(departmentRepository),
          generalSettingsRepositoryProvider.overrideWithValue(
            generalSettingsRepository,
          ),
          officialHolidayRepositoryProvider.overrideWithValue(
            officialHolidayRepository,
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: const PayrollTab(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(employeeRepository.loadCount, 0);
    expect(attendanceRepository.loadCount, 0);

    await pullToRefresh(tester, find.byType(ListView));

    expect(employeeRepository.loadCount, 1);
    expect(attendanceRepository.loadCount, 1);
  });
}
