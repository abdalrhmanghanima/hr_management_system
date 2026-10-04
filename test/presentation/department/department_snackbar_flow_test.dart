import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/department/departments_screen.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/department/widgets/add_department_bottom_sheet.dart';
import 'package:hr_management_system/presentation/shared_widgets/app_floating_action_button.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';

class _DuplicateDepartmentRepository extends FakeDepartmentRepository {
  _DuplicateDepartmentRepository()
    : super(const [DepartmentEntity(id: 'dep-1', name: 'Engineering')]);
}

class _SavingDepartmentRepository extends FakeDepartmentRepository {
  _SavingDepartmentRepository() : super(const []);

  final List<String> mutations = [];

  @override
  Future<void> addDepartment(DepartmentEntity department) async {
    mutations.add('add');
  }
}

class _FailingDepartmentRepository extends FakeDepartmentRepository {
  _FailingDepartmentRepository() : super(const []);

  @override
  Future<void> addDepartment(DepartmentEntity department) async {
    throw StateError('write rejected');
  }
}

void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    required List<Override> overrides,
  }) async {
    tester.view.physicalSize = const Size(480, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapWithLocalization(
        ProviderScope(
          overrides: overrides,
          child: TestApp(home: screen),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<void> openSheetAndSave(WidgetTester tester, String name) async {
    await tester.tap(find.byType(AppFloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AddDepartmentBottomSheet), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(AddDepartmentBottomSheet),
        matching: find.byType(TextFormField),
      ),
      name,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(AddDepartmentBottomSheet),
        matching: find.widgetWithText(CustomButton, 'Save Department'),
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

  group('Add Department BottomSheet SnackBar flow', () {
    testWidgets(
      'duplicate save closes the sheet before the error SnackBar is shown',
      (tester) async {
        await pumpScreen(
          tester,
          const DepartmentsScreen(),
          overrides: [
            fullAccessAuthorizationOverride(),
            departmentRepositoryProvider
                .overrideWithValue(_DuplicateDepartmentRepository()),
          ],
        );

        await openSheetAndSave(tester, 'Engineering');

        expect(find.byType(AddDepartmentBottomSheet), findsNothing);
        expect(find.byType(BottomSheet), findsNothing);

        final message = find.text('A department with this name already exists');
        expect(message, findsOneWidget);
        expect(
          find.ancestor(
            of: find.byType(SnackBar),
            matching: find.byType(DepartmentsScreen),
          ),
          findsOneWidget,
        );
        expect(snackBarTextIsReachable(tester, message), isTrue);
      },
    );

    testWidgets(
      'failed save closes the sheet and shows the error SnackBar',
      (tester) async {
        await pumpScreen(
          tester,
          const DepartmentsScreen(),
          overrides: [
            fullAccessAuthorizationOverride(),
            departmentRepositoryProvider
                .overrideWithValue(_FailingDepartmentRepository()),
          ],
        );

        await openSheetAndSave(tester, 'Marketing');

        expect(find.byType(AddDepartmentBottomSheet), findsNothing);
        expect(find.byType(BottomSheet), findsNothing);

        final message = find.text('Failed to add department. Please try again');
        expect(message, findsOneWidget);
        expect(snackBarTextIsReachable(tester, message), isTrue);
      },
    );

    testWidgets(
      'successful save shows the success SnackBar after the sheet closes',
      (tester) async {
        final repository = _SavingDepartmentRepository();

        await pumpScreen(
          tester,
          const DepartmentsScreen(),
          overrides: [
            fullAccessAuthorizationOverride(),
            departmentRepositoryProvider.overrideWithValue(repository),
          ],
        );

        await openSheetAndSave(tester, 'Marketing');

        expect(repository.mutations, ['add']);
        expect(find.byType(AddDepartmentBottomSheet), findsNothing);
        expect(find.byType(BottomSheet), findsNothing);

        final message = find.text('Department added successfully');
        expect(message, findsOneWidget);
        expect(
          find.ancestor(
            of: find.byType(SnackBar),
            matching: find.byType(DepartmentsScreen),
          ),
          findsOneWidget,
        );
        expect(snackBarTextIsReachable(tester, message), isTrue);
      },
    );
  });
}
