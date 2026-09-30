import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/enums/save_result.dart';
import 'package:hr_management_system/domain/department/entity/department_entity.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/domain/official_holiday/entity/official_holiday_entity.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';
import 'package:hr_management_system/presentation/department/provider/department_provider.dart';
import 'package:hr_management_system/presentation/employee/providers/employee_provider.dart';
import 'package:hr_management_system/presentation/official_holiday/provider/official_holidays_provider.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/authorization_test_data.dart';

class RecordingDepartmentRepository extends FakeDepartmentRepository {
  final List<String> mutations = [];

  @override
  Future<void> addDepartment(DepartmentEntity department) async {
    mutations.add('add');
  }

  @override
  Future<void> updateDepartment(DepartmentEntity department) async {
    mutations.add('update');
  }

  @override
  Future<void> deleteDepartment(String id) async {
    mutations.add('delete');
  }
}

class RecordingEmployeeRepository extends FakeEmployeeRepository {
  RecordingEmployeeRepository([super.employees]);

  final List<String> mutations = [];

  @override
  Future<void> addEmployee(EmployeeEntity employee) async {
    mutations.add('add');
  }

  @override
  Future<void> updateEmployee(EmployeeEntity employee) async {
    mutations.add('update');
  }

  @override
  Future<void> deleteEmployee(String id) async {
    mutations.add('delete');
  }
}

class RecordingOfficialHolidayRepository
    extends FakeOfficialHolidayRepository {
  final List<String> mutations = [];

  @override
  Future<void> addOfficialHoliday(OfficialHolidayEntity holiday) async {
    mutations.add('add');
  }

  @override
  Future<void> updateOfficialHoliday(OfficialHolidayEntity holiday) async {
    mutations.add('update');
  }

  @override
  Future<void> deleteOfficialHoliday(String id) async {
    mutations.add('delete');
  }
}

void main() {
  final holiday = OfficialHolidayEntity(
    id: 'hol-1',
    name: 'New Year',
    date: DateTime(2026, 1, 1),
  );

  ProviderContainer buildContainer(
    List<Override> repositoryOverrides, {
    required GroupPermissionEntity permission,
  }) {
    final container = ProviderContainer(
      overrides: [
        authorizationProvider.overrideWith(
          () => FakeAuthorizationNotifier(
            buildTestAuthorization(
              fullAccess: false,
              permissions: {GroupModules.departments: permission},
            ),
          ),
        ),
        ...repositoryOverrides,
      ],
    );

    addTearDown(container.dispose);

    return container;
  }

  group('Department mutations', () {
    test('are rejected without the matching permission', () async {
      final repository = RecordingDepartmentRepository();
      final container = buildContainer(
        [departmentRepositoryProvider.overrideWithValue(repository)],
        permission: const GroupPermissionEntity(view: true),
      );

      await container.read(authorizationProvider.future);

      final notifier = container.read(departmentProvider.notifier);

      expect(
        await notifier.addDepartment(
          const DepartmentEntity(id: 'dep-2', name: 'Sales'),
        ),
        SaveResult.failure,
      );
      expect(
        await notifier.updateDepartment(
          const DepartmentEntity(id: 'dep-2', name: 'Sales'),
        ),
        SaveResult.failure,
      );
      await notifier.deleteDepartment('dep-2');

      expect(repository.mutations, isEmpty);
    });

    test('are allowed with the matching permission', () async {
      final repository = RecordingDepartmentRepository();
      final container = buildContainer(
        [departmentRepositoryProvider.overrideWithValue(repository)],
        permission: const GroupPermissionEntity(
          view: true,
          add: true,
          edit: true,
          delete: true,
        ),
      );

      await container.read(authorizationProvider.future);

      final notifier = container.read(departmentProvider.notifier);

      expect(
        await notifier.addDepartment(
          const DepartmentEntity(id: 'dep-2', name: 'Sales'),
        ),
        SaveResult.success,
      );
      expect(
        await notifier.updateDepartment(
          const DepartmentEntity(id: 'dep-2', name: 'Sales'),
        ),
        SaveResult.success,
      );
      await notifier.deleteDepartment('dep-2');

      expect(repository.mutations, ['add', 'update', 'delete']);
    });
  });

  group('Official holiday mutations', () {
    List<Override> overridesFor(
      RecordingOfficialHolidayRepository repository, {
      required GroupPermissionEntity permission,
    }) {
      return [
        authorizationProvider.overrideWith(
          () => FakeAuthorizationNotifier(
            buildTestAuthorization(
              fullAccess: false,
              permissions: {GroupModules.officialHolidays: permission},
            ),
          ),
        ),
        officialHolidayRepositoryProvider.overrideWithValue(repository),
      ];
    }

    test('are rejected without the matching permission', () async {
      final repository = RecordingOfficialHolidayRepository();
      final container = ProviderContainer(
        overrides: overridesFor(
          repository,
          permission: const GroupPermissionEntity(view: true),
        ),
      );
      addTearDown(container.dispose);

      await container.read(authorizationProvider.future);

      final notifier = container.read(officialHolidaysProvider.notifier);

      expect(
        await notifier.addOfficialHoliday(holiday),
        SaveResult.failure,
      );
      expect(
        await notifier.updateOfficialHoliday(holiday),
        SaveResult.failure,
      );
      expect(await notifier.deleteOfficialHoliday('hol-1'), isFalse);

      expect(repository.mutations, isEmpty);
    });

    test('are allowed with the matching permission', () async {
      final repository = RecordingOfficialHolidayRepository();
      final container = ProviderContainer(
        overrides: overridesFor(
          repository,
          permission: const GroupPermissionEntity(
            view: true,
            add: true,
            edit: true,
            delete: true,
          ),
        ),
      );
      addTearDown(container.dispose);

      await container.read(authorizationProvider.future);

      final notifier = container.read(officialHolidaysProvider.notifier);

      expect(
        await notifier.addOfficialHoliday(holiday),
        SaveResult.success,
      );
      expect(
        await notifier.updateOfficialHoliday(holiday),
        SaveResult.success,
      );
      expect(await notifier.deleteOfficialHoliday('hol-1'), isTrue);

      expect(repository.mutations, ['add', 'update', 'delete']);
    });
  });

  group('Employee mutations', () {
    List<Override> overridesFor(
      RecordingEmployeeRepository repository, {
      required GroupPermissionEntity permission,
    }) {
      return [
        authorizationProvider.overrideWith(
          () => FakeAuthorizationNotifier(
            buildTestAuthorization(
              fullAccess: false,
              permissions: {GroupModules.employees: permission},
            ),
          ),
        ),
        employeeRepositoryProvider.overrideWithValue(repository),
      ];
    }

    test('are rejected without the matching permission', () async {
      final repository = RecordingEmployeeRepository();
      final container = ProviderContainer(
        overrides: overridesFor(
          repository,
          permission: const GroupPermissionEntity(view: true),
        ),
      );
      addTearDown(container.dispose);

      await container.read(authorizationProvider.future);

      final notifier = container.read(employeeProvider.notifier);

      expect(await notifier.addEmployee(buildEmployee()), SaveResult.failure);
      expect(
        await notifier.updateEmployee(buildEmployee()),
        SaveResult.failure,
      );
      await notifier.deleteEmployee(testEmployeeId);

      expect(repository.mutations, isEmpty);
    });

    test('are allowed with the matching permission', () async {
      final repository = RecordingEmployeeRepository([]);
      final container = ProviderContainer(
        overrides: overridesFor(
          repository,
          permission: const GroupPermissionEntity(
            view: true,
            add: true,
            edit: true,
            delete: true,
          ),
        ),
      );
      addTearDown(container.dispose);

      await container.read(authorizationProvider.future);

      final notifier = container.read(employeeProvider.notifier);

      expect(await notifier.addEmployee(buildEmployee()), SaveResult.success);
      expect(
        await notifier.updateEmployee(buildEmployee()),
        SaveResult.success,
      );
      await notifier.deleteEmployee(testEmployeeId);

      expect(repository.mutations, ['add', 'update', 'delete']);
    });
  });

  group('Permission action mapping', () {
    test('each action is required independently', () {
      const addOnly = GroupPermissionEntity(view: true, add: true);
      const editOnly = GroupPermissionEntity(view: true, edit: true);
      const deleteOnly = GroupPermissionEntity(view: true, delete: true);

      expect(addOnly.isGranted(PermissionAction.view), isTrue);
      expect(addOnly.isGranted(PermissionAction.add), isTrue);
      expect(addOnly.isGranted(PermissionAction.edit), isFalse);
      expect(addOnly.isGranted(PermissionAction.delete), isFalse);

      expect(editOnly.isGranted(PermissionAction.edit), isTrue);
      expect(editOnly.isGranted(PermissionAction.delete), isFalse);

      expect(deleteOnly.isGranted(PermissionAction.delete), isTrue);
      expect(deleteOnly.isGranted(PermissionAction.add), isFalse);
    });
  });
}
