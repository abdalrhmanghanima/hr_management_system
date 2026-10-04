import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/provider/selected_attendance_month_provider.dart';
import 'package:hr_management_system/presentation/attendance/tab/attendance_tab.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/components/month_filter_row/month_year_picker_dialog.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';

Future<void> tapByKey(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('attendance list follows the month filter', (tester) async {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, 15);
    final previousDate = DateTime(now.year, now.month - 1, 15);

    var targetMonth = now.month + 3;
    var targetYear = now.year;

    if (targetMonth > 12) {
      targetMonth -= 12;
      targetYear += 1;
    }

    final employeeRepository = FakeEmployeeRepository();
    final attendanceRepository = FakeAttendanceRepository([
      buildAttendance(
        id: 'att-current',
        date: currentDate,
        checkIn: DateTime(currentDate.year, currentDate.month, 15, 8),
        checkOut: DateTime(currentDate.year, currentDate.month, 15, 17),
      ),
      buildAttendance(
        id: 'att-previous',
        date: previousDate,
        checkIn: DateTime(previousDate.year, previousDate.month, 15, 8),
        checkOut: DateTime(previousDate.year, previousDate.month, 15, 17),
      ),
    ]);
    final departmentRepository = FakeDepartmentRepository();

    tester.view.physicalSize = const Size(480, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        fullAccessAuthorizationOverride(),
        employeeRepositoryProvider.overrideWithValue(employeeRepository),
        attendanceRepositoryProvider.overrideWithValue(attendanceRepository),
        departmentRepositoryProvider.overrideWithValue(departmentRepository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(employeeProvider.notifier).getEmployees();
    await container.read(attendanceProvider.notifier).getAttendances();

    await tester.pumpWidget(
      wrapWithLocalization(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            navigatorKey: navigatorKey,
            home: const AttendanceTab(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Current Month'), findsOneWidget);
    expect(
      find.text(DateParser.toDisplayDate(currentDate)),
      findsOneWidget,
    );
    expect(find.text(DateParser.toDisplayDate(previousDate)), findsNothing);

    await tapByKey(tester, const ValueKey('month-filter-chip-previous'));

    expect(
      container.read(selectedAttendanceMonthProvider),
      DateTime(now.year, now.month - 1),
    );
    expect(
      find.text(DateParser.toDisplayDate(previousDate)),
      findsOneWidget,
    );
    expect(find.text(DateParser.toDisplayDate(currentDate)), findsNothing);

    await tapByKey(tester, const ValueKey('month-filter-chip-choose'));

    expect(find.byType(MonthYearPickerDialog), findsOneWidget);

    final pickerYear =
        DateTime(now.year, now.month - 1).year;

    if (targetYear != pickerYear) {
      final yearKey = targetYear > pickerYear
          ? const ValueKey('month-picker-year-next')
          : const ValueKey('month-picker-year-prev');

      await tester.tap(find.byKey(yearKey));
      await tester.pumpAndSettle();
    }

    await tester.tap(
      find.byKey(ValueKey('month-picker-option-$targetMonth')),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(selectedAttendanceMonthProvider),
      DateTime(targetYear, targetMonth),
    );
    expect(
      find.text(AppLocalization.monthYearValue(targetYear, targetMonth)),
      findsOneWidget,
    );
    expect(find.byType(AttendanceRecordCard), findsNothing);
    expect(find.byType(MonthYearPickerDialog), findsNothing);

    await tapByKey(tester, const ValueKey('month-filter-chip-current'));

    expect(
      container.read(selectedAttendanceMonthProvider),
      DateTime(now.year, now.month),
    );
    expect(
      find.text(DateParser.toDisplayDate(currentDate)),
      findsOneWidget,
    );
    expect(find.byType(AttendanceRecordCard), findsOneWidget);
  });
}
