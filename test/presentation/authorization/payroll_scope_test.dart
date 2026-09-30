import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';
import 'package:hr_management_system/presentation/attendance/provider/attendance_provider.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/more/provider/general_settings_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';
import 'package:hr_management_system/presentation/payroll/provider/payroll_provider.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';

const String currentEmployeeId = 'EMP001';

const String otherEmployeeId = 'EMP002';

const String payrollMonth = '2026-09-01';

class ListQueryForbiddenEmployeeRepository extends FakeEmployeeRepository {
  ListQueryForbiddenEmployeeRepository(super.employees);

  @override
  Future<List<EmployeeEntity>> getEmployees() {
    throw StateError('PERMISSION_DENIED: query on employees was rejected');
  }
}

void main() {
  final employees = [
    buildEmployee(id: currentEmployeeId, nationalId: '29801011234567'),
    buildEmployee(
      id: otherEmployeeId,
      nationalId: '29801019999999',
      fullName: 'Sara Ibrahim',
    ),
  ];

  final attendances = [
    buildAttendance(
      id: 'att-1',
      employeeId: currentEmployeeId,
      date: DateTime.parse(payrollMonth),
      checkIn: DateTime.parse('$payrollMonth 08:00'),
      checkOut: DateTime.parse('$payrollMonth 17:00'),
    ),
    buildAttendance(
      id: 'att-2',
      employeeId: otherEmployeeId,
      date: DateTime.parse(payrollMonth),
      checkIn: DateTime.parse('$payrollMonth 08:00'),
      checkOut: DateTime.parse('$payrollMonth 09:00'),
    ),
  ];

  List<Override> buildOverrides(GroupPermissionEntity payrollPermission) {
    return [
      authorizationProvider.overrideWith(
        () => FakeAuthorizationNotifier(
          buildTestAuthorization(
            employeeId: currentEmployeeId,
            fullAccess: false,
            permissions: {GroupModules.payroll: payrollPermission},
          ),
        ),
      ),
      employeeRepositoryProvider.overrideWithValue(
        FakeEmployeeRepository([...employees]),
      ),
      attendanceRepositoryProvider.overrideWithValue(
        FakeAttendanceRepository([...attendances]),
      ),
      generalSettingsRepositoryProvider.overrideWithValue(
        FakeGeneralSettingsRepository(),
      ),
      officialHolidayRepositoryProvider.overrideWithValue(
        FakeOfficialHolidayRepository(),
      ),
    ];
  }

  Future<ProviderContainer> buildContainer(
    GroupPermissionEntity payrollPermission,
  ) async {
    final container = ProviderContainer(
      overrides: [
        ...buildOverrides(payrollPermission),
        currentPayrollMonthProvider.overrideWith(
          (ref) => DateTime.parse(payrollMonth),
        ),
      ],
    );

    await container.read(authorizationProvider.future);
    await container.read(employeeProvider.notifier).getEmployees();
    await container.read(attendanceProvider.notifier).getAttendances();
    await container.read(officialHolidaysProvider.notifier).getOfficialHolidays();
    await container.read(generalSettingsProvider.future);

    return container;
  }

  group('Payroll scope', () {
    test('own scope keeps only the current employee', () async {
      final container = await buildContainer(
        const GroupPermissionEntity(view: true, scope: PermissionScope.own),
      );
      addTearDown(container.dispose);

      final visible = (await container.read(payrollVisibleEmployeesProvider.future))
          .map((employee) => employee.id);

      expect(visible, [currentEmployeeId]);
    });

    test('all scope keeps every employee', () async {
      final container = await buildContainer(
        const GroupPermissionEntity(view: true, scope: PermissionScope.all),
      );
      addTearDown(container.dispose);

      final visible = (await container.read(payrollVisibleEmployeesProvider.future))
          .map((employee) => employee.id);

      expect(visible, [currentEmployeeId, otherEmployeeId]);
    });

    test('no view permission hides every employee', () async {
      final container = await buildContainer(const GroupPermissionEntity());
      addTearDown(container.dispose);

      expect(
        await container.read(payrollVisibleEmployeesProvider.future),
        isEmpty,
      );
    });

    test('own scope calculates payroll for the current employee only', () async {
      final container = await buildContainer(
        const GroupPermissionEntity(view: true, scope: PermissionScope.own),
      );
      addTearDown(container.dispose);

      final summaries = await container.read(payrollSummariesProvider.future);

      expect(summaries, hasLength(1));
      expect(summaries.single.employeeId, currentEmployeeId);
    });

    test('all scope calculates payroll for every employee', () async {
      final container = await buildContainer(
        const GroupPermissionEntity(view: true, scope: PermissionScope.all),
      );
      addTearDown(container.dispose);

      final summaries = await container.read(payrollSummariesProvider.future);

      expect(
        summaries.map((summary) => summary.employeeId).toList(),
        [currentEmployeeId, otherEmployeeId],
      );
    });

    test('own scope does not count another employee attendance', () async {
      final container = await buildContainer(
        const GroupPermissionEntity(view: true, scope: PermissionScope.own),
      );
      addTearDown(container.dispose);

      final summaries = await container.read(payrollSummariesProvider.future);
      final summary = summaries.single;

      expect(summary.employeeId, currentEmployeeId);
      expect(summary.overtimeHours, 1);
    });

    test('denied scope produces no payroll summaries', () async {
      final container = await buildContainer(const GroupPermissionEntity());
      addTearDown(container.dispose);

      expect(await container.read(payrollSummariesProvider.future), isEmpty);
    });

    test('own scope works without a permitted employees list query', () async {
      final container = ProviderContainer(
        overrides: [
          ...buildOverrides(
            const GroupPermissionEntity(
              view: true,
              scope: PermissionScope.own,
            ),
          ),
          currentPayrollMonthProvider.overrideWith(
            (ref) => DateTime.parse(payrollMonth),
          ),
          employeeRepositoryProvider.overrideWithValue(
            ListQueryForbiddenEmployeeRepository([...employees]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authorizationProvider.future);
      await container.read(attendanceProvider.notifier).getAttendances();
      await container.read(generalSettingsProvider.future);
      await container.read(officialHolidaysProvider.future);

      final visible = await container.read(payrollVisibleEmployeesProvider.future);

      expect(visible.map((employee) => employee.id), [currentEmployeeId]);

      final summaries = await container.read(payrollSummariesProvider.future);

      expect(summaries.single.employeeId, currentEmployeeId);
    });
  });
}
