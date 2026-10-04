import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/components/month_filter_row/month_year_picker_dialog.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';
import 'package:hr_management_system/presentation/payroll/tab/payroll_tab.dart';

import '../../helpers/localization_test_helper.dart';
import '../../helpers/payroll_test_data.dart';

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

Future<void> tapByKey(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

Future<void> pumpPayrollTab(
  WidgetTester tester,
  ProviderContainer container,
) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    wrapWithLocalization(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(navigatorKey: navigatorKey, home: const PayrollTab()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('payroll list follows the month filter', (tester) async {
    ignoreRenderFlexOverflows();

    final container = await createPayrollTestContainer();

    await pumpPayrollTab(tester, container);

    expect(container.read(selectedPayrollMonthProvider), payrollTestMonth);
    expect(find.text('Current Month'), findsOneWidget);
    expect(find.textContaining('• September 2026'), findsOneWidget);

    await tapByKey(tester, const ValueKey('month-filter-chip-previous'));

    expect(container.read(selectedPayrollMonthProvider), DateTime(2026, 8));
    expect(find.textContaining('August 2026'), findsOneWidget);
    expect(find.textContaining('September 2026'), findsNothing);

    await tapByKey(tester, const ValueKey('month-filter-chip-current'));

    expect(container.read(selectedPayrollMonthProvider), payrollTestMonth);
    expect(find.textContaining('September 2026'), findsOneWidget);
    expect(find.textContaining('August 2026'), findsNothing);

    await tapByKey(tester, const ValueKey('month-filter-chip-choose'));

    expect(find.byType(MonthYearPickerDialog), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('month-picker-option-12')),
    );
    await tester.pumpAndSettle();

    expect(container.read(selectedPayrollMonthProvider), DateTime(2026, 12));
    expect(find.text('December 2026'), findsOneWidget);
    expect(find.textContaining('• December 2026'), findsOneWidget);
    expect(find.textContaining('• September 2026'), findsNothing);
  });
}
