import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/components/month_filter_row/month_filter_row.dart';
import 'package:hr_management_system/presentation/components/month_filter_row/month_year_picker_dialog.dart';

import '../../helpers/localization_test_helper.dart';

const Key currentChipKey = ValueKey('month-filter-chip-current');
const Key previousChipKey = ValueKey('month-filter-chip-previous');
const Key chooseChipKey = ValueKey('month-filter-chip-choose');

Future<void> pumpRow(
  WidgetTester tester, {
  required List<DateTime> pickedMonths,
  required DateTime selectedMonth,
  DateTime? currentMonth,
  Locale locale = AppLocalization.en,
}) async {
  tester.view.physicalSize = const Size(480, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await pumpLocalized(
    tester,
    Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MonthFilterRow(
          selectedMonth: selectedMonth,
          currentMonth: currentMonth,
          onMonthChanged: pickedMonths.add,
        ),
      ),
    ),
    navigatorKey: navigatorKey,
    locale: locale,
  );
}

Future<void> tapChip(WidgetTester tester, Key chipKey) async {
  await tester.ensureVisible(find.byKey(chipKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(chipKey));
  await tester.pumpAndSettle();
}

Color? chipColor(WidgetTester tester, Key chipKey) {
  final container = tester.widget<Container>(
    find
        .descendant(of: find.byKey(chipKey), matching: find.byType(Container))
        .first,
  );

  return (container.decoration! as BoxDecoration).color;
}

void main() {
  group('MonthFilterRow', () {
    testWidgets('selects the current month by default', (tester) async {
      final pickedMonths = <DateTime>[];

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2026, 9),
        currentMonth: DateTime(2026, 9),
      );

      expect(find.text('Current Month'), findsOneWidget);
      expect(find.text('Previous Month'), findsOneWidget);
      expect(find.text('Choose Month'), findsOneWidget);

      expect(chipColor(tester, currentChipKey), AppColors.primary);
      expect(chipColor(tester, previousChipKey), AppColors.white);
      expect(chipColor(tester, chooseChipKey), AppColors.white);
    });

    testWidgets('previous month crosses the year boundary', (tester) async {
      final pickedMonths = <DateTime>[];

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2027, 1),
        currentMonth: DateTime(2027, 1),
      );

      await tapChip(tester, previousChipKey);

      expect(pickedMonths, [DateTime(2026, 12)]);
    });

    testWidgets('marks previous month as selected after a year transition', (
      tester,
    ) async {
      final pickedMonths = <DateTime>[];

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2026, 12),
        currentMonth: DateTime(2027, 1),
      );

      expect(chipColor(tester, previousChipKey), AppColors.primary);
      expect(chipColor(tester, currentChipKey), AppColors.white);
      expect(chipColor(tester, chooseChipKey), AppColors.white);
      expect(find.text('Choose Month'), findsOneWidget);
    });

    testWidgets('tapping the current month filter selects it', (
      tester,
    ) async {
      final pickedMonths = <DateTime>[];

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2026, 6),
        currentMonth: DateTime(2026, 9),
      );

      expect(chipColor(tester, chooseChipKey), AppColors.primary);

      await tapChip(tester, currentChipKey);

      expect(pickedMonths, [DateTime(2026, 9)]);
    });

    testWidgets('choose month opens the picker and reports the selection', (
      tester,
    ) async {
      final pickedMonths = <DateTime>[];

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2026, 9),
        currentMonth: DateTime(2026, 9),
      );

      await tapChip(tester, chooseChipKey);

      expect(find.byType(MonthYearPickerDialog), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('month-picker-option-3')),
      );
      await tester.pumpAndSettle();

      expect(pickedMonths, [DateTime(2026, 3)]);
      expect(find.byType(MonthYearPickerDialog), findsNothing);
    });

    testWidgets('picking the current month keeps the current filter active', (
      tester,
    ) async {
      final pickedMonths = <DateTime>[];

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2026, 9),
        currentMonth: DateTime(2026, 9),
      );

      await tapChip(tester, chooseChipKey);

      await tester.tap(
        find.byKey(const ValueKey('month-picker-option-9')),
      );
      await tester.pumpAndSettle();

      expect(pickedMonths, [DateTime(2026, 9)]);

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2026, 9),
        currentMonth: DateTime(2026, 9),
      );

      expect(chipColor(tester, currentChipKey), AppColors.primary);
      expect(chipColor(tester, chooseChipKey), AppColors.white);
      expect(find.text('Choose Month'), findsOneWidget);
      expect(find.text('September 2026'), findsNothing);
    });

    testWidgets('choose month picker navigates across year boundaries', (
      tester,
    ) async {
      final pickedMonths = <DateTime>[];

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2027, 1),
        currentMonth: DateTime(2027, 1),
      );

      await tapChip(tester, chooseChipKey);

      expect(find.text('2027'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('month-picker-year-prev')));
      await tester.pumpAndSettle();

      expect(find.text('2026'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('month-picker-option-12')),
      );
      await tester.pumpAndSettle();

      expect(pickedMonths, [DateTime(2026, 12)]);
    });

    testWidgets('reflects the chosen month with a single active filter', (
      tester,
    ) async {
      final pickedMonths = <DateTime>[];

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2027, 3),
        currentMonth: DateTime(2027, 1),
      );

      expect(find.text('March 2027'), findsOneWidget);
      expect(find.text('Choose Month'), findsNothing);

      expect(chipColor(tester, chooseChipKey), AppColors.primary);
      expect(chipColor(tester, currentChipKey), AppColors.white);
      expect(chipColor(tester, previousChipKey), AppColors.white);
    });

    testWidgets('shows Arabic labels in RTL', (tester) async {
      final pickedMonths = <DateTime>[];

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2026, 9),
        currentMonth: DateTime(2026, 9),
        locale: AppLocalization.ar,
      );

      expect(find.text('الشهر الحالي'), findsOneWidget);
      expect(find.text('الشهر السابق'), findsOneWidget);
      expect(find.text('اختر الشهر'), findsOneWidget);

      final currentCenter = tester.getCenter(find.byKey(currentChipKey)).dx;
      final previousCenter = tester.getCenter(find.byKey(previousChipKey)).dx;

      expect(currentCenter, greaterThan(previousCenter));
    });

    testWidgets('lays chips left to right in LTR', (tester) async {
      final pickedMonths = <DateTime>[];

      await pumpRow(
        tester,
        pickedMonths: pickedMonths,
        selectedMonth: DateTime(2026, 9),
        currentMonth: DateTime(2026, 9),
      );

      final currentCenter = tester.getCenter(find.byKey(currentChipKey)).dx;
      final previousCenter = tester.getCenter(find.byKey(previousChipKey)).dx;

      expect(currentCenter, lessThan(previousCenter));
    });
  });
}
