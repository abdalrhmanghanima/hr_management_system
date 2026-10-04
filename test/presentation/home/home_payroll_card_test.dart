import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/home/provider/bottom_nav_provider.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab.dart';
import 'package:hr_management_system/presentation/home/tabs/home_tab_item.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';

void main() {
  group('Home current month payroll card', () {
    testWidgets('shows the total net payroll and opens payroll tab', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
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
          generalSettingsRepositoryProvider.overrideWithValue(
            FakeGeneralSettingsRepository(),
          ),
          officialHolidayRepositoryProvider.overrideWithValue(
            FakeOfficialHolidayRepository(),
          ),
          currentPayrollMonthProvider.overrideWith(
            (ref) => DateTime(2026, 9),
          ),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        wrapWithLocalization(
          UncontrolledProviderScope(
            container: container,
            child: TestApp(navigatorKey: navigatorKey, home: const HomeTab()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('TOTAL CURRENT MONTH NET PAYROLL'),
        findsOneWidget,
      );
      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('EGP'), findsOneWidget);

      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();

      expect(container.read(currentHomeTabProvider), HomeTabItem.payroll);
    });
  });
}
