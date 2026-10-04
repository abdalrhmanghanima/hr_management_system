import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';
import 'package:hr_management_system/presentation/payroll/screens/official_salary_slip_screen.dart';
import 'package:hr_management_system/presentation/payroll/screens/payroll_details_screen.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';
import '../../helpers/payroll_test_data.dart';

Future<void> pumpDetailsScreen(
  WidgetTester tester,
  ProviderContainer container,
) async {
  tester.view.physicalSize = const Size(480, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    wrapWithLocalization(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          navigatorKey: navigatorKey,
          home: const PayrollDetailsScreen(employeeId: testEmployeeId),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('Payroll details screen', () {
    testWidgets('shows payroll breakdown, statistics and reference', (
      tester,
    ) async {
      final container = await createPayrollTestContainer();

      await pumpDetailsScreen(tester, container);

      expect(find.text('Payroll Details'), findsOneWidget);
      expect(find.text('Ahmed Mohamed'), findsOneWidget);
      expect(find.text('Engineering • September 2026'), findsOneWidget);
      expect(find.text('REF. #PAY-EMP001-202609'), findsOneWidget);
      expect(find.text('Attendance Statistics'), findsOneWidget);
      expect(find.text('Financial Breakdown'), findsOneWidget);
      expect(find.text('Attendance Days'), findsOneWidget);
      expect(find.text('Absence Days'), findsOneWidget);
      expect(find.text('Overtime Hours'), findsOneWidget);
      expect(find.text('Deduction Hours'), findsOneWidget);
      expect(find.text('Basic Salary'), findsOneWidget);
      expect(find.text('Total Overtime Addition'), findsOneWidget);
      expect(find.text('Total Absence / Hours Deduction'), findsOneWidget);
      expect(find.text('Net Monthly Salary'), findsOneWidget);
      expect(find.text('View & Print Salary Slip'), findsOneWidget);
      expect(find.textContaining('EGP'), findsWidgets);
    });

    testWidgets('opens the official salary slip screen', (tester) async {
      final container = await createPayrollTestContainer();

      await pumpDetailsScreen(tester, container);

      await tester.tap(find.text('View & Print Salary Slip'));
      await tester.pumpAndSettle();

      expect(find.byType(OfficialSalarySlipScreen), findsOneWidget);
      expect(find.text('Official Salary Slip'), findsOneWidget);
    });

    testWidgets('respects the selected payroll month', (tester) async {
      final container = await createPayrollTestContainer(
        extraOverrides: [
          selectedPayrollMonthProvider.overrideWith(
            (ref) => DateTime(2026, 8),
          ),
        ],
      );

      await pumpDetailsScreen(tester, container);

      expect(find.text('Engineering • August 2026'), findsOneWidget);
      expect(find.text('REF. #PAY-EMP001-202608'), findsOneWidget);
      expect(find.textContaining('September 2026'), findsNothing);
    });

    testWidgets('is blocked without payroll view permission', (tester) async {
      tester.view.physicalSize = const Size(480, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrapWithLocalization(
          ProviderScope(
            overrides: [
              ...payrollDataOverrides(
                authorization: authorizationProvider.overrideWith(
                  () => FakeAuthorizationNotifier(
                    buildTestAuthorization(fullAccess: false),
                  ),
                ),
              ),
            ],
            child: TestApp(
              navigatorKey: navigatorKey,
              home: const PayrollDetailsScreen(employeeId: testEmployeeId),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('You do not have access to this section.'),
        findsOneWidget,
      );
    });
  });
}
