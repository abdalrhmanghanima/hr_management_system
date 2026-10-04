import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/localization/app_localization.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/employee/tab/employee_tab.dart';
import 'package:hr_management_system/presentation/employee/widgets/department_filter_row.dart';
import 'package:hr_management_system/presentation/employee/widgets/employee_card.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';

const Key allChipKey = ValueKey('department-filter-chip-all');
const Key managementChipKey = ValueKey('department-filter-chip-dep-management');
const Key financeChipKey = ValueKey('department-filter-chip-dep-finance');
const Key engineeringChipKey = ValueKey('department-filter-chip-dep-1');
const Key hrChipKey = ValueKey('department-filter-chip-dep-hr');

const List<DepartmentEntity> filterDepartments = [
  DepartmentEntity(id: 'dep-management', name: 'Management'),
  DepartmentEntity(id: 'dep-finance', name: 'Finance'),
  DepartmentEntity(id: 'dep-1', name: 'Engineering'),
];

List<EmployeeEntity> filterEmployees() {
  return [
    buildEmployee(
      id: 'EMP001',
      fullName: 'Ahmed Ali',
      departmentId: 'dep-management',
    ),
    buildEmployee(
      id: 'EMP002',
      fullName: 'Sara Hassan',
      departmentId: 'dep-finance',
    ),
    buildEmployee(
      id: 'EMP003',
      fullName: 'Ahmed Nasser',
      departmentId: 'dep-1',
    ),
  ];
}

Future<void> pumpEmployeesTab(
  WidgetTester tester, {
  required FakeEmployeeRepository employeeRepository,
  required FakeDepartmentRepository departmentRepository,
  Locale locale = AppLocalization.en,
}) async {
  tester.view.physicalSize = const Size(480, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    wrapWithLocalization(
      ProviderScope(
        overrides: [
          fullAccessAuthorizationOverride(),
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          departmentRepositoryProvider.overrideWithValue(departmentRepository),
        ],
        child: TestApp(
          navigatorKey: navigatorKey,
          home: const EmployeesTab(),
        ),
      ),
      locale: locale,
    ),
  );
  await tester.pumpAndSettle();
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

List<String> shownEmployeeNames(WidgetTester tester) {
  return tester
      .widgetList<EmployeeCard>(find.byType(EmployeeCard))
      .map((card) => card.name)
      .toList();
}

void main() {
  group('Employees department filter', () {
    testWidgets('displays the All category', (tester) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
      );

      expect(find.byKey(allChipKey), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('All is selected by default', (tester) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
      );

      expect(chipColor(tester, allChipKey), AppColors.primary);
      expect(chipColor(tester, managementChipKey), AppColors.white);
      expect(chipColor(tester, financeChipKey), AppColors.white);
    });

    testWidgets('displays all employees when All is selected', (tester) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
      );

      expect(shownEmployeeNames(tester), [
        'Ahmed Ali',
        'Sara Hassan',
        'Ahmed Nasser',
      ]);
    });

    testWidgets('loads departments dynamically from the department provider', (
      tester,
    ) async {
      final departmentRepository = FakeDepartmentRepository(filterDepartments);

      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: departmentRepository,
      );

      expect(departmentRepository.loadCount, greaterThan(0));
      expect(find.byKey(managementChipKey), findsOneWidget);
      expect(find.byKey(financeChipKey), findsOneWidget);
      expect(find.byKey(engineeringChipKey), findsOneWidget);
    });

    testWidgets('shows every department as a category', (tester) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
      );

      final categoryRow = find.byType(DepartmentFilterRow);

      expect(
        find.descendant(of: categoryRow, matching: find.text('Management')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: categoryRow, matching: find.text('Finance')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: categoryRow, matching: find.text('Engineering')),
        findsOneWidget,
      );
    });

    testWidgets('filters employees by departmentId when selected', (
      tester,
    ) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
      );

      await tapChip(tester, engineeringChipKey);

      expect(shownEmployeeNames(tester), ['Ahmed Nasser']);
    });

    testWidgets('selecting Management only displays Management employees', (
      tester,
    ) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
      );

      await tapChip(tester, managementChipKey);

      expect(shownEmployeeNames(tester), ['Ahmed Ali']);
    });

    testWidgets('selecting Finance only displays Finance employees', (
      tester,
    ) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
      );

      await tapChip(tester, financeChipKey);

      expect(shownEmployeeNames(tester), ['Sara Hassan']);
    });

    testWidgets('selecting All restores every employee', (tester) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
      );

      await tapChip(tester, managementChipKey);

      expect(shownEmployeeNames(tester), ['Ahmed Ali']);

      await tapChip(tester, allChipKey);

      expect(shownEmployeeNames(tester), [
        'Ahmed Ali',
        'Sara Hassan',
        'Ahmed Nasser',
      ]);
      expect(chipColor(tester, allChipKey), AppColors.primary);
    });

    testWidgets('combines search with the department filter', (tester) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
      );

      await tester.enterText(find.byType(TextFormField), 'ahmed');
      await tester.pumpAndSettle();

      expect(shownEmployeeNames(tester), ['Ahmed Ali', 'Ahmed Nasser']);

      await tapChip(tester, managementChipKey);

      expect(shownEmployeeNames(tester), ['Ahmed Ali']);
    });

    testWidgets('changing the department keeps the search query', (
      tester,
    ) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
      );

      await tester.enterText(find.byType(TextFormField), 'ahmed');
      await tester.pumpAndSettle();

      await tapChip(tester, engineeringChipKey);

      expect(shownEmployeeNames(tester), ['Ahmed Nasser']);
      expect(find.text('ahmed'), findsOneWidget);
    });

    testWidgets('shows the localized empty state for a department without employees', (
      tester,
    ) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository([
          ...filterDepartments,
          const DepartmentEntity(id: 'dep-hr', name: 'HR'),
        ]),
      );

      await tapChip(tester, hrChipKey);

      expect(find.text('No employees found'), findsOneWidget);
      expect(find.byType(EmployeeCard), findsNothing);
    });

    testWidgets('category row scrolls horizontally without overflow', (
      tester,
    ) async {
      final manyDepartments = [
        for (var index = 0; index < 12; index++)
          DepartmentEntity(id: 'dep-$index', name: 'Department Number $index'),
      ];

      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(manyDepartments),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      final lastChipKey = const ValueKey('department-filter-chip-dep-11');

      await tester.scrollUntilVisible(
        find.byKey(lastChipKey),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(lastChipKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('localizes the All category in Arabic', (tester) async {
      await pumpEmployeesTab(
        tester,
        employeeRepository: FakeEmployeeRepository(filterEmployees()),
        departmentRepository: FakeDepartmentRepository(filterDepartments),
        locale: AppLocalization.ar,
      );

      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('All'), findsNothing);
    });
  });
}
