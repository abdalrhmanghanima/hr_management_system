import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/utils/delete_confirmation_dialog.dart';
import 'package:hr_management_system/core/utils/sign_out_confirmation_dialog.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';

import '../helpers/localization_test_helper.dart';

void _noop() {}

Future<void> _openDialog(WidgetTester tester, Widget dialog) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await pumpLocalized(
    tester,
    Builder(
      builder: (context) => Center(
        child: ElevatedButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => dialog,
          ),
          child: const Text('open'),
        ),
      ),
    ),
    navigatorKey: navigatorKey,
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('DeleteConfirmationDialog still confirms with Delete', (
    tester,
  ) async {
    await _openDialog(
      tester,
      DeleteConfirmationDialog(
        title: 'Delete item',
        message: 'Are you sure?',
        onDelete: _noop,
      ),
    );

    expect(find.widgetWithText(CustomButton, 'Delete'), findsOneWidget);
    expect(find.widgetWithText(CustomButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(CustomButton, 'Sign Out'), findsNothing);
  });

  testWidgets('SignOutConfirmationDialog confirms with Sign Out', (
    tester,
  ) async {
    await _openDialog(
      tester,
      SignOutConfirmationDialog(
        title: 'Sign Out',
        message: 'Are you sure?',
        onDelete: _noop,
      ),
    );

    expect(find.widgetWithText(CustomButton, 'Sign Out'), findsOneWidget);
    expect(find.widgetWithText(CustomButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(CustomButton, 'Delete'), findsNothing);
  });
}
