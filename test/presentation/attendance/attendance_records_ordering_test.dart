import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_attendance_month_provider.dart';
import 'package:hr_management_system/presentation/attendance/tab/attendance_tab.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';

const Key previousChipKey = ValueKey('month-filter-chip-previous');

List<DateTime> shownDates(WidgetTester tester) {
  return tester
      .widgetList<AttendanceRecordCard>(find.byType(AttendanceRecordCard))
      .map((card) => card.date)
      .toList();
}

AttendanceEntity attendanceOn(DateTime date) {
  return buildAttendance(
    id: 'att-${date.year}-${date.month}-${date.day}',
    date: date,
    checkIn: DateTime(date.year, date.month, date.day, 9),
    checkOut: DateTime(date.year, date.month, date.day, 17),
  );
}

Future<void> pumpAttendanceTab(
  WidgetTester tester, {
  required List<AttendanceEntity> attendances,
  required DateTime selectedMonth,
}) async {
  tester.view.physicalSize = const Size(480, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      fullAccessAuthorizationOverride(),
      employeeRepositoryProvider.overrideWithValue(FakeEmployeeRepository()),
      attendanceRepositoryProvider.overrideWithValue(
        FakeAttendanceRepository(attendances),
      ),
      departmentRepositoryProvider.overrideWithValue(
        FakeDepartmentRepository(),
      ),
      selectedAttendanceMonthProvider.overrideWith((ref) => selectedMonth),
    ],
  );
  addTearDown(container.dispose);

  await container.read(employeeProvider.notifier).getEmployees();
  await container.read(attendanceProvider.notifier).getAttendances();

  await tester.pumpWidget(
    wrapWithLocalization(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(navigatorKey: navigatorKey, home: const AttendanceTab()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapByKey(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows 30/09/2026 before 29/09/2026 in descending order', (
    tester,
  ) async {
    await pumpAttendanceTab(
      tester,
      selectedMonth: DateTime(2026, 9),
      attendances: [
        attendanceOn(DateTime(2026, 9, 27)),
        attendanceOn(DateTime(2026, 9, 28)),
        attendanceOn(DateTime(2026, 9, 29)),
        attendanceOn(DateTime(2026, 9, 30)),
      ],
    );

    expect(shownDates(tester), [
      DateTime(2026, 9, 30),
      DateTime(2026, 9, 29),
      DateTime(2026, 9, 28),
      DateTime(2026, 9, 27),
    ]);

    expect(find.text('30/09/2026'), findsOneWidget);
    expect(find.text('29/09/2026'), findsOneWidget);

    final newestTop = tester.getTopLeft(find.text('30/09/2026')).dy;
    final nextTop = tester.getTopLeft(find.text('29/09/2026')).dy;

    expect(newestTop, lessThan(nextTop));
  });

  testWidgets('newer attendance records always appear before older records', (
    tester,
  ) async {
    await pumpAttendanceTab(
      tester,
      selectedMonth: DateTime(2026, 9),
      attendances: [
        attendanceOn(DateTime(2026, 9, 30)),
        attendanceOn(DateTime(2026, 9, 27)),
        attendanceOn(DateTime(2026, 9, 29)),
        attendanceOn(DateTime(2026, 9, 28)),
      ],
    );

    expect(shownDates(tester), [
      DateTime(2026, 9, 30),
      DateTime(2026, 9, 29),
      DateTime(2026, 9, 28),
      DateTime(2026, 9, 27),
    ]);
  });

  testWidgets('keeps descending order after changing the month filter', (
    tester,
  ) async {
    final now = DateTime.now();
    final currentRecords = [
      DateTime(now.year, now.month, 3),
      DateTime(now.year, now.month, 8),
      DateTime(now.year, now.month, 15),
    ];
    final previousRecords = [
      DateTime(now.year, now.month - 1, 5),
      DateTime(now.year, now.month - 1, 10),
    ];

    await pumpAttendanceTab(
      tester,
      selectedMonth: DateTime(now.year, now.month),
      attendances: [
        attendanceOn(currentRecords[0]),
        attendanceOn(previousRecords[0]),
        attendanceOn(currentRecords[2]),
        attendanceOn(currentRecords[1]),
        attendanceOn(previousRecords[1]),
      ],
    );

    expect(shownDates(tester), [
      currentRecords[2],
      currentRecords[1],
      currentRecords[0],
    ]);

    await tapByKey(tester, previousChipKey);

    expect(shownDates(tester), [previousRecords[1], previousRecords[0]]);
  });
}
