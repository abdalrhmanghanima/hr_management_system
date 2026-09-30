import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/group/data_source/group_remote_data_source.dart';
import 'package:hr_management_system/data/group/model/group_model.dart';
import 'package:hr_management_system/data/group/model/group_permission_model.dart';
import 'package:hr_management_system/data/group/repository/group_repository_impl.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/employee/repository/employee_repository.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';

class FakeGroupRemoteDataSource implements GroupRemoteDataSource {
  FakeGroupRemoteDataSource([List<GroupModel>? groups])
    : groups = {for (final group in groups ?? const <GroupModel>[]) group.id: group};

  final Map<String, GroupModel> groups;

  int setGroupMembersCallCount = 0;

  @override
  Future<List<GroupModel>> getGroups() async => groups.values.toList();

  @override
  Future<GroupModel?> getGroupById(String id) async => groups[id];

  @override
  Future<GroupModel?> getGroupByName(String name, {String? excludingId}) async {
    final target = name.trim().toLowerCase();

    for (final group in groups.values) {
      if (group.id == excludingId) continue;
      if (group.name.trim().toLowerCase() == target) return group;
    }

    return null;
  }

  @override
  Future<void> addGroup(GroupModel group) async {
    groups[group.id] = group;
  }

  @override
  Future<void> updateGroup(GroupModel group) async {
    groups[group.id] = group;
  }

  @override
  Future<void> deleteGroup(String id) async {
    groups.remove(id);
  }

  @override
  Future<void> setGroupMembers(String groupId, List<String> employeeIds) async {
    setGroupMembersCallCount++;

    final group = groups[groupId];
    if (group == null) throw StateError('Group $groupId does not exist');

    groups[groupId] = GroupModel(
      id: group.id,
      name: group.name,
      description: group.description,
      employeeIds: employeeIds,
      permissions: group.permissions,
    );
  }
}

class FakeGroupEmployeeRepository implements EmployeeRepository {
  FakeGroupEmployeeRepository([List<EmployeeEntity>? employees])
    : employees = employees ?? [];

  final List<EmployeeEntity> employees;

  @override
  Future<List<EmployeeEntity>> getEmployees() async => employees;

  @override
  Future<EmployeeEntity> getEmployeeById(String id) async {
    return employees.firstWhere((employee) => employee.id == id);
  }

  @override
  Future<EmployeeEntity?> getEmployeeByNationalId(
    String nationalId, {
    String? excludingId,
  }) => throw UnimplementedError();

  @override
  Future<void> addEmployee(EmployeeEntity employee) =>
      throw UnimplementedError();

  @override
  Future<void> updateEmployee(EmployeeEntity employee) =>
      throw UnimplementedError();

  @override
  Future<void> deleteEmployee(String id) => throw UnimplementedError();

  @override
  Future<void> linkEmployeeAccount(String id, String authUid) =>
      throw UnimplementedError();
}

class FakeGroupAuthRepo implements AuthRepo {
  final Map<String, String?> groupByUid = {};

  final Map<String, String> employeeIdByUid = {};

  @override
  Future<UserEntity> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<UserEntity?> getUserByUid(String uid) => throw UnimplementedError();

  @override
  Future<void> updateUserGroup({
    required String uid,
    required String employeeId,
    String? groupId,
  }) async {
    employeeIdByUid[uid] = employeeId;
    groupByUid[uid] = groupId;
  }
}

EmployeeEntity buildGroupEmployee(String id, {String? authUid}) {
  return EmployeeEntity(
    id: id,
    fullName: 'Employee $id',
    address: 'Cairo',
    phoneNumber: '01000000000',
    birthDate: DateTime(1990, 1, 1),
    nationalId: '29801011${id.hashCode.abs() % 100000}',
    nationality: 'Egyptian',
    gender: 'Male',
    departmentId: 'dep-1',
    contractDate: DateTime(2024, 1, 1),
    salary: 15000,
    hasAccount: authUid != null,
    authUid: authUid,
  );
}

void main() {
  late FakeGroupRemoteDataSource dataSource;
  late FakeGroupAuthRepo authRepo;
  late GroupRepositoryImpl repository;

  setUp(() {
    dataSource = FakeGroupRemoteDataSource();
    authRepo = FakeGroupAuthRepo();
    repository = GroupRepositoryImpl(
      dataSource: dataSource,
      employeeRepository: FakeGroupEmployeeRepository([
        buildGroupEmployee('e1', authUid: 'uid-1'),
        buildGroupEmployee('e2', authUid: 'uid-2'),
        buildGroupEmployee('e3', authUid: 'uid-3'),
        buildGroupEmployee('e4'),
      ]),
      authRepo: authRepo,
    );
  });

  group('one group per employee', () {
    test('adding a group removes its members from their previous group', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-hr', name: 'HR', employeeIds: ['e1']),
      );
      await repository.addGroup(
        const GroupEntity(id: 'g-ops', name: 'Operations', employeeIds: ['e1', 'e2']),
      );

      expect(dataSource.groups['g-hr']!.employeeIds, isEmpty);
      expect(dataSource.groups['g-ops']!.employeeIds, ['e1', 'e2']);
    });

    test('an employee appears in exactly one group after several saves', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-a', name: 'A', employeeIds: ['e1']),
      );
      await repository.addGroup(
        const GroupEntity(id: 'g-b', name: 'B', employeeIds: ['e1']),
      );
      await repository.addGroup(
        const GroupEntity(id: 'g-c', name: 'C', employeeIds: ['e1']),
      );

      final groupsWithEmployee = dataSource.groups.values
          .where((group) => group.employeeIds.contains('e1'))
          .toList();

      expect(groupsWithEmployee, hasLength(1));
      expect(groupsWithEmployee.single.id, 'g-c');
    });

    test('updating a group also detaches members moved from another group', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-hr', name: 'HR', employeeIds: ['e1', 'e2']),
      );
      await repository.updateGroup(
        const GroupEntity(id: 'g-ops', name: 'Operations', employeeIds: ['e2']),
      );

      expect(dataSource.groups['g-hr']!.employeeIds, ['e1']);
      expect(dataSource.groups['g-ops']!.employeeIds, ['e2']);
    });

    test('unrelated groups are left untouched', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-hr', name: 'HR', employeeIds: ['e1']),
      );
      await repository.addGroup(
        const GroupEntity(id: 'g-pay', name: 'Payroll', employeeIds: ['e3']),
      );

      final writesBefore = dataSource.setGroupMembersCallCount;

      await repository.addGroup(
        const GroupEntity(id: 'g-ops', name: 'Operations', employeeIds: ['e2']),
      );

      expect(dataSource.setGroupMembersCallCount, writesBefore);
      expect(dataSource.groups['g-pay']!.employeeIds, ['e3']);
    });
  });

  group('users document synchronization', () {
    test('assigning a group writes groupId for members that have accounts', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-hr', name: 'HR', employeeIds: ['e1', 'e2']),
      );

      expect(authRepo.groupByUid['uid-1'], 'g-hr');
      expect(authRepo.groupByUid['uid-2'], 'g-hr');
    });

    test('an employee without an account is still a member but has no user doc', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-hr', name: 'HR', employeeIds: ['e4']),
      );

      expect(dataSource.groups['g-hr']!.employeeIds, ['e4']);
      expect(authRepo.employeeIdByUid, isEmpty);
    });

    test('moving an employee rewrites the groupId of both memberships', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-hr', name: 'HR', employeeIds: ['e1']),
      );
      await repository.addGroup(
        const GroupEntity(id: 'g-ops', name: 'Operations', employeeIds: ['e1']),
      );

      expect(authRepo.groupByUid['uid-1'], 'g-ops');
    });

    test('removing a member clears their groupId', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-hr', name: 'HR', employeeIds: ['e1', 'e2']),
      );
      await repository.updateGroup(
        const GroupEntity(id: 'g-hr', name: 'HR', employeeIds: ['e1']),
      );

      expect(authRepo.groupByUid['uid-1'], 'g-hr');
      expect(authRepo.groupByUid['uid-2'], isNull);
    });

    test('deleting a group clears the groupId of every member', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-hr', name: 'HR', employeeIds: ['e1', 'e2']),
      );
      await repository.deleteGroup('g-hr');

      expect(dataSource.groups, isEmpty);
      expect(authRepo.groupByUid['uid-1'], isNull);
      expect(authRepo.groupByUid['uid-2'], isNull);
    });

    test('deleting a group keeps members of other groups assigned', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-hr', name: 'HR', employeeIds: ['e1']),
      );
      await repository.addGroup(
        const GroupEntity(id: 'g-pay', name: 'Payroll', employeeIds: ['e3']),
      );
      await repository.deleteGroup('g-hr');

      expect(authRepo.groupByUid['uid-1'], isNull);
      expect(authRepo.groupByUid['uid-3'], 'g-pay');
    });

    test('syncEmployeeUser links a new account to the current group', () async {
      await repository.addGroup(
        const GroupEntity(id: 'g-pay', name: 'Payroll', employeeIds: ['e3']),
      );

      await repository.syncEmployeeUser('e3');

      expect(authRepo.groupByUid['uid-3'], 'g-pay');
    });

    test('syncEmployeeUser clears the link when the employee has no group', () async {
      await repository.syncEmployeeUser('e1');

      expect(authRepo.groupByUid['uid-1'], isNull);
    });
  });

  group('group name lookup', () {
    test('matches a name regardless of casing and surrounding spaces', () async {
      await repository.addGroup(const GroupEntity(id: 'g-hr', name: 'HR'));

      final match = await repository.getGroupByName('  hr ');

      expect(match?.id, 'g-hr');
    });

    test('excluding a group id ignores the group itself', () async {
      await repository.addGroup(const GroupEntity(id: 'g-hr', name: 'HR'));

      final match = await repository.getGroupByName('HR', excludingId: 'g-hr');

      expect(match, isNull);
    });
  });

  group('firestore serialization', () {
    test('a group round trips through the firestore representation', () {
      const group = GroupEntity(
        id: 'g-hr',
        name: 'HR',
        description: 'HR access',
        employeeIds: ['e1', 'e2'],
        permissions: {
          'employees': GroupPermissionEntity(
            view: true,
            add: true,
            scope: PermissionScope.all,
          ),
          'attendance': GroupPermissionEntity(view: true),
        },
      );

      final model = GroupModel.fromEntity(group);
      final data = model.toFirestore();

      expect(data['name'], 'HR');
      expect(data['description'], 'HR access');
      expect(data['employeeIds'], ['e1', 'e2']);
      expect(
        (data['permissions'] as Map)['employees'],
        containsPair('scope', 'all'),
      );
      expect((data['permissions'] as Map)['attendance'], containsPair('view', true));
    });

    test('a missing scope is read back as null', () {
      final permission = GroupPermissionModel.fromFirestore({
        'view': true,
        'add': false,
        'edit': false,
        'delete': false,
        'scope': null,
      });

      expect(permission.scope, isNull);
      expect(permission.isGranted(PermissionAction.view), isTrue);
      expect(permission.isGranted(PermissionAction.delete), isFalse);
    });

    test('an unknown scope key falls back to no scope', () {
      final permission = GroupPermissionModel.fromFirestore({'scope': 'global'});

      expect(permission.scope, isNull);
    });

    test('a missing permission entry yields an empty permission', () {
      const group = GroupEntity(id: 'g-hr', name: 'HR');

      expect(group.permissionFor('payroll').hasAnyGrant, isFalse);
      expect(group.membersCount, 0);
    });
  });

  group('permission entity', () {
    test('toggling an action only flips the requested action', () {
      const permission = GroupPermissionEntity(view: true, add: true);

      final toggled = permission.toggleAction(PermissionAction.add);

      expect(toggled.isGranted(PermissionAction.add), isFalse);
      expect(toggled.isGranted(PermissionAction.view), isTrue);
    });

    test('changing the scope keeps the granted actions', () {
      const permission = GroupPermissionEntity(edit: true, delete: true);

      final updated = permission.withScope(PermissionScope.all);

      expect(updated.scope, PermissionScope.all);
      expect(updated.isGranted(PermissionAction.edit), isTrue);
      expect(updated.isGranted(PermissionAction.delete), isTrue);
    });
  });
}
