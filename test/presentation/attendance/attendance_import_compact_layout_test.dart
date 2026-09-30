import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/main.dart';
import '../../helpers/localization_test_helper.dart';
import 'package:hr_management_system/presentation/attendance/attendance_import_screen.dart';

void main() {
  testWidgets('renders without overflow on a compact screen', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapWithLocalization(
        ProviderScope(
          child: TestApp(
            navigatorKey: navigatorKey,
            home: const AttendanceImportScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('attendance_import.title'.tr()), findsWidgets);
    expect(find.text('attendance_import.choose_file'.tr()), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
