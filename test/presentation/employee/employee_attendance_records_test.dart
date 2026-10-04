import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/core/utils/date_parser.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/attendance/employee_attendance_records_screen.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/attendance/widgets/attendance_record_card.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/employee_details.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';

const Key showRecordsKey = ValueKey('show-attendance-records-action');
const Key currentChipKey = ValueKey('month-filter-chip-current');
const Key previousChipKey = ValueKey('month-filter-chip-previous');

Future<void> tapByKey(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

ProviderContainer createRecordsContainer({
  List<AttendanceEntity> attendances = const [],
  bool fullAccess = true,
}) {
  final container = ProviderContainer(
    overrides: [
      fullAccess
          ? fullAccessAuthorizationOverride(employeeId: testEmployeeId)
          : authorizationProvider.overrideWith(
              () => FakeAuthorizationNotifier(
                buildTestAuthorization(fullAccess: false),
              ),
            ),
      employeeRepositoryProvider.overrideWithValue(FakeEmployeeRepository()),
      attendanceRepositoryProvider.overrideWithValue(
        FakeAttendanceRepository(attendances),
      ),
      departmentRepositoryProvider.overrideWithValue(
        FakeDepartmentRepository(),
      ),
      generalSettingsRepositoryProvider.overrideWithValue(
        FakeGeneralSettingsRepository(),
      ),
    ],
  );

  addTearDown(container.dispose);

  return container;
}

Future<void> pumpEmployeeDetails(
  WidgetTester tester,
  ProviderContainer container, {
  Locale locale = AppLocalization.en,
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    wrapWithLocalization(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          navigatorKey: navigatorKey,
          home: const EmployeeDetails(employeeId: testEmployeeId),
        ),
      ),
      locale: locale,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpRecordsScreen(
  WidgetTester tester,
  ProviderContainer container, {
  Locale locale = AppLocalization.en,
  Size surface = const Size(800, 1600),
}) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    wrapWithLocalization(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          navigatorKey: navigatorKey,
          home: const EmployeeAttendanceRecordsScreen(
            employeeId: testEmployeeId,
          ),
        ),
      ),
      locale: locale,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Show Attendance Records action', () {
    testWidgets('sits in the Today\'s Attendance header row', (tester) async {
      final container = createRecordsContainer();

      await pumpEmployeeDetails(tester, container);

      await tester.ensureVisible(find.byKey(showRecordsKey));
      await tester.pumpAndSettle();

      expect(find.byKey(showRecordsKey), findsOneWidget);
      expect(find.text('Show Attendance Records'), findsOneWidget);

      final headerRow = find
          .ancestor(
            of: find.byKey(showRecordsKey),
            matching: find.byType(Row),
          )
          .first;

      expect(
        find.descendant(
          of: headerRow,
          matching: find.text("Today's Attendance"),
        ),
        findsOneWidget,
      );
    });

    testWidgets('opens the employee attendance records screen', (
      tester,
    ) async {
      final container = createRecordsContainer(
        attendances: [
          buildAttendance(
            id: 'att-current',
            date: DateTime(DateTime.now().year, DateTime.now().month, 5),
            checkIn: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              5,
              9,
            ),
            checkOut: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              5,
              18,
            ),
          ),
        ],
      );

      await pumpEmployeeDetails(tester, container);

      await tapByKey(tester, showRecordsKey);

      expect(find.byType(EmployeeAttendanceRecordsScreen), findsOneWidget);
      expect(find.text('Employee Attendance Records'), findsOneWidget);
      expect(find.text('Current Month'), findsOneWidget);
      expect(find.byType(AttendanceRecordCard), findsOneWidget);
    });

    testWidgets('localizes the action and screen title in Arabic', (
      tester,
    ) async {
      final container = createRecordsContainer();

      await pumpEmployeeDetails(tester, container, locale: AppLocalization.ar);

      await tester.ensureVisible(find.byKey(showRecordsKey));
      await tester.pumpAndSettle();

      expect(find.text('عرض سجلات الحضور'), findsOneWidget);

      await pumpRecordsScreen(
        tester,
        container,
        locale: AppLocalization.ar,
      );

      expect(find.text('سجلات حضور الموظف'), findsOneWidget);
    });
  });

  group('Employee attendance records screen', () {
    testWidgets('shows the employee name and department header', (
      tester,
    ) async {
      final container = createRecordsContainer();

      await pumpRecordsScreen(tester, container);

      expect(find.text('Employee Attendance Records'), findsOneWidget);
      expect(find.text('Ahmed Mohamed'), findsWidgets);
      expect(find.text('Engineering'), findsWidgets);
    });

    testWidgets('shows worked, overtime and deduction hours per record', (
      tester,
    ) async {
      final now = DateTime.now();
      final recordDate = DateTime(now.year, now.month, 5);

      final container = createRecordsContainer(
        attendances: [
          buildAttendance(
            id: 'att-hours',
            date: recordDate,
            checkIn: DateTime(now.year, now.month, 5, 9),
            checkOut: DateTime(now.year, now.month, 5, 18),
          ),
        ],
      );

      await pumpRecordsScreen(tester, container);

      expect(find.byType(AttendanceRecordCard), findsOneWidget);
      expect(find.text('Worked'), findsOneWidget);
      expect(find.text('Overtime'), findsOneWidget);
      expect(find.text('Deduction'), findsOneWidget);
      expect(find.text('9.0 hrs'), findsOneWidget);
      expect(find.text('1.0 hrs'), findsOneWidget);
      expect(find.text('0.0 hrs'), findsOneWidget);
    });

    testWidgets('defaults to the current month and this employee only', (
      tester,
    ) async {
      final now = DateTime.now();
      final currentDate = DateTime(now.year, now.month, 5);
      final otherEmployeeDate = DateTime(now.year, now.month, 6);
      final oldDate = DateTime(now.year, now.month - 3, 10);

      final container = createRecordsContainer(
        attendances: [
          buildAttendance(
            id: 'att-current',
            date: currentDate,
            checkIn: DateTime(now.year, now.month, 5, 9),
            checkOut: DateTime(now.year, now.month, 5, 17),
          ),
          buildAttendance(
            id: 'att-other-employee',
            employeeId: 'EMP002',
            date: otherEmployeeDate,
            checkIn: DateTime(now.year, now.month, 6, 9),
            checkOut: DateTime(now.year, now.month, 6, 17),
          ),
          buildAttendance(
            id: 'att-old',
            date: oldDate,
            checkIn: DateTime(
              oldDate.year,
              oldDate.month,
              10,
              9,
            ),
            checkOut: DateTime(
              oldDate.year,
              oldDate.month,
              10,
              17,
            ),
          ),
        ],
      );

      await pumpRecordsScreen(tester, container);

      expect(find.text('Current Month'), findsOneWidget);
      expect(find.byType(AttendanceRecordCard), findsOneWidget);
      expect(
        find.text(DateParser.toDisplayDate(currentDate)),
        findsOneWidget,
      );
      expect(
        find.text(DateParser.toDisplayDate(otherEmployeeDate)),
        findsNothing,
      );
      expect(find.text(DateParser.toDisplayDate(oldDate)), findsNothing);
    });

    testWidgets('switching the month filter changes the records', (
      tester,
    ) async {
      final now = DateTime.now();
      final currentDate = DateTime(now.year, now.month, 5);
      final previousDate = DateTime(now.year, now.month - 1, 8);

      final container = createRecordsContainer(
        attendances: [
          buildAttendance(
            id: 'att-current',
            date: currentDate,
            checkIn: DateTime(now.year, now.month, 5, 9),
            checkOut: DateTime(now.year, now.month, 5, 17),
          ),
          buildAttendance(
            id: 'att-previous',
            date: previousDate,
            checkIn: DateTime(
              previousDate.year,
              previousDate.month,
              8,
              9,
            ),
            checkOut: DateTime(
              previousDate.year,
              previousDate.month,
              8,
              17,
            ),
          ),
        ],
      );

      await pumpRecordsScreen(tester, container);

      expect(find.byKey(currentChipKey), findsOneWidget);
      expect(
        find.text(DateParser.toDisplayDate(currentDate)),
        findsOneWidget,
      );
      expect(find.text(DateParser.toDisplayDate(previousDate)), findsNothing);

      await tapByKey(tester, previousChipKey);

      expect(
        find.text(DateParser.toDisplayDate(previousDate)),
        findsOneWidget,
      );
      expect(find.text(DateParser.toDisplayDate(currentDate)), findsNothing);
    });

    testWidgets('displays the newest attendance record first', (
      tester,
    ) async {
      final now = DateTime.now();
      final dates = [
        DateTime(now.year, now.month, 5),
        DateTime(now.year, now.month, 15),
        DateTime(now.year, now.month, 25),
      ];

      final container = createRecordsContainer(
        attendances: [
          for (final date in dates)
            buildAttendance(
              id: 'att-${date.day}',
              date: date,
              checkIn: DateTime(date.year, date.month, date.day, 9),
              checkOut: DateTime(date.year, date.month, date.day, 17),
            ),
        ],
      );

      await pumpRecordsScreen(
        tester,
        container,
        surface: const Size(800, 2600),
      );

      final shownDates = tester
          .widgetList<AttendanceRecordCard>(find.byType(AttendanceRecordCard))
          .map((card) => card.date)
          .toList();

      expect(shownDates, [dates[2], dates[1], dates[0]]);
    });

    testWidgets('shows a localized empty state without records', (
      tester,
    ) async {
      final container = createRecordsContainer();

      await pumpRecordsScreen(tester, container);

      expect(find.text('No attendance records found'), findsOneWidget);
      expect(find.byType(AttendanceRecordCard), findsNothing);
    });

    testWidgets('is blocked without attendance view permission', (
      tester,
    ) async {
      final container = createRecordsContainer(fullAccess: false);

      await pumpRecordsScreen(tester, container);

      expect(
        find.text('You do not have access to this section.'),
        findsOneWidget,
      );
      expect(find.byType(AttendanceRecordCard), findsNothing);
    });
  });
}
