import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/utils/update_confirmation_dialog.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/presentation/attendance/edit_attendance_screen.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';

class _FailingAttendanceRepository extends FakeAttendanceRepository {
  _FailingAttendanceRepository() : super([buildAttendance(id: 'att-1')]);

  @override
  Future<void> updateAttendance(AttendanceEntity attendance) async {
    throw StateError('write rejected');
  }
}

void main() {
  Future<void> pumpEditAttendance(
    WidgetTester tester, {
    required List<Override> overrides,
  }) async {
    tester.view.physicalSize = const Size(480, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapWithLocalization(
        ProviderScope(
          overrides: overrides,
          child: const TestApp(home: Scaffold(body: SizedBox.shrink())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute(
        builder: (_) => EditAttendanceScreen(
          attendance: buildAttendance(id: 'att-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> confirmUpdate(WidgetTester tester) async {
    await tester.tap(
      find.widgetWithText(CustomButton, 'Update Attendance'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(UpdateConfirmationDialog), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(UpdateConfirmationDialog),
        matching: find.widgetWithText(CustomButton, 'Update Attendance'),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool snackBarTextIsReachable(WidgetTester tester, Finder message) {
    final messageRect = tester.getRect(message);
    final messageRender = tester.renderObject(message);
    final targets = tester
        .hitTestOnBinding(messageRect.center)
        .path
        .map((entry) => entry.target)
        .toList();

    return targets.contains(messageRender);
  }

  group('Edit Attendance SnackBar feedback', () {
    testWidgets(
      'successful update shows the success SnackBar after the screen pops',
      (tester) async {
        final repository = FakeAttendanceRepository([
          buildAttendance(id: 'att-1'),
        ]);

        await pumpEditAttendance(
          tester,
          overrides: [
            fullAccessAuthorizationOverride(),
            attendanceRepositoryProvider.overrideWithValue(repository),
            employeeRepositoryProvider.overrideWithValue(
              FakeEmployeeRepository(),
            ),
          ],
        );

        await confirmUpdate(tester);

        expect(repository.updatedIds, contains('att-1'));
        expect(find.byType(EditAttendanceScreen), findsNothing);

        final message = find.text('Attendance updated successfully');
        expect(message, findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(snackBarTextIsReachable(tester, message), isTrue);
      },
    );

    testWidgets(
      'failed update shows the error SnackBar and keeps the screen open',
      (tester) async {
        await pumpEditAttendance(
          tester,
          overrides: [
            fullAccessAuthorizationOverride(),
            attendanceRepositoryProvider
                .overrideWithValue(_FailingAttendanceRepository()),
            employeeRepositoryProvider.overrideWithValue(
              FakeEmployeeRepository(),
            ),
          ],
        );

        await confirmUpdate(tester);

        expect(find.byType(EditAttendanceScreen), findsOneWidget);

        final message = find.text(
          'Failed to update attendance. Please try again',
        );
        expect(message, findsOneWidget);
        expect(snackBarTextIsReachable(tester, message), isTrue);
      },
    );
  });
}
