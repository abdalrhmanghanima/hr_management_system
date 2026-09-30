import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/authorization/repository/authorization_repository_impl.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/domain/authorization/service/employee_scope.dart';
import 'package:hr_management_system/domain/authorization/service/module_access.dart';
import 'package:hr_management_system/domain/authorization/service/permission_checker.dart';
import 'package:hr_management_system/domain/authorization/use_case/load_authorization.dart';
import 'package:hr_management_system/domain/attendance/entity/attendance_entity.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/domain/employee/entity/employee_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';
import 'package:hr_management_system/domain/group/repository/group_repository.dart';

class _FakeAuthRepo implements AuthRepo {
  _FakeAuthRepo(this.user);

  final UserEntity? user;

  @override
  Future<UserEntity?> getUserByUid(String uid) async => user;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> updateUserGroup({
    required String uid,
    required String employeeId,
    String? groupId,
  }) async {}
}

class _FakeGroupRepository implements GroupRepository {
  _FakeGroupRepository(this.group);

  final GroupEntity? group;

  @override
  Future<List<GroupEntity>> getGroups() async =>
      group == null ? const [] : [group!];

  @override
  Future<GroupEntity?> getGroupById(String id) async => group;

  @override
  Future<GroupEntity?> getGroupByName(
    String name, {
    String? excludingId,
  }) async => group;

  @override
  Future<void> addGroup(GroupEntity group) async {}

  @override
  Future<void> updateGroup(GroupEntity group) async {}

  @override
  Future<void> deleteGroup(String id) async {}

  @override
  Future<void> syncEmployeeUser(String employeeId) async {}
}

const _fullAccess = GroupPermissionEntity(
  view: true,
  add: true,
  edit: true,
  delete: true,
  scope: PermissionScope.all,
);

const _ownAccess = GroupPermissionEntity(
  view: true,
  add: true,
  edit: true,
  delete: false,
  scope: PermissionScope.own,
);

const _emptyAccess = GroupPermissionEntity();

GroupEntity _group(Map<String, GroupPermissionEntity> permissions) {
  return GroupEntity(
    id: 'group-1',
    name: 'HR',
    description: '',
    employeeIds: const ['employee-1'],
    permissions: permissions,
  );
}

Future<AuthorizationEntity> _load({
  UserEntity? user,
  GroupEntity? group,
  String uid = 'uid-1',
}) {
  return LoadAuthorization(
    AuthorizationRepositoryImpl(
      authRepo: _FakeAuthRepo(user),
      groupRepository: _FakeGroupRepository(group),
    ),
  ).call(uid);
}

void main() {
  group('AuthorizationRepositoryImpl', () {
    test('returns unauthenticated when uid is empty', () async {
      final result = await _load(uid: '');

      expect(result.status, AuthorizationStatus.unauthenticated);
      expect(result.isResolved, isFalse);
    });

    test('returns missingUserDocument when user document does not exist', () async {
      final result = await _load();

      expect(result.status, AuthorizationStatus.missingUserDocument);
    });

    test('returns inactive when the user document is not active', () async {
      final result = await _load(
        user: const UserEntity(
          uid: 'uid-1',
          email: 'a@b.com',
          employeeId: 'employee-1',
          groupId: 'group-1',
          isActive: false,
        ),
        group: _group(const {}),
      );

      expect(result.status, AuthorizationStatus.inactive);
    });

    test('returns withoutGroup when the user has no group', () async {
      final result = await _load(
        user: const UserEntity(
          uid: 'uid-1',
          email: 'a@b.com',
          employeeId: 'employee-1',
        ),
      );

      expect(result.status, AuthorizationStatus.withoutGroup);
    });

    test('returns groupNotFound when the referenced group is missing', () async {
      final result = await _load(
        user: const UserEntity(
          uid: 'uid-1',
          email: 'a@b.com',
          employeeId: 'employee-1',
          groupId: 'group-1',
        ),
      );

      expect(result.status, AuthorizationStatus.groupNotFound);
    });

    test('returns authenticated with permissions for a valid user', () async {
      final result = await _load(
        user: const UserEntity(
          uid: 'uid-1',
          email: 'a@b.com',
          employeeId: 'employee-1',
          groupId: 'group-1',
        ),
        group: _group(const {'employees': _fullAccess}),
      );

      expect(result.status, AuthorizationStatus.authenticated);
      expect(result.isResolved, isTrue);
      expect(result.employeeId, 'employee-1');
      expect(result.groupId, 'group-1');
      expect(result.groupName, 'HR');
      expect(result.canView(GroupModules.employees), isTrue);
      expect(result.canDelete(GroupModules.attendance), isFalse);
    });
  });

  group('AuthorizationEntity permissions', () {
    final authenticated = AuthorizationEntity(
      status: AuthorizationStatus.authenticated,
      uid: 'uid-1',
      email: 'a@b.com',
      employeeId: 'employee-1',
      groupId: 'group-1',
      group: _group(const {
        'employees': _fullAccess,
        'attendance': _ownAccess,
        'payroll': _fullAccess,
      }),
      permissions: const {
        'employees': _fullAccess,
        'attendance': _ownAccess,
        'payroll': _fullAccess,
      },
    );

    test('missing module permissions are denied', () {
      expect(authenticated.canView(GroupModules.departments), isFalse);
      expect(authenticated.canAdd(GroupModules.groups), isFalse);
    });

    test('unresolved authorization denies every permission', () {
      const loading = AuthorizationEntity.loading();
      const unauthenticated = AuthorizationEntity.unauthenticated();

      for (final authorization in [loading, unauthenticated]) {
        for (final module in GroupModules.all) {
          expect(authorization.canView(module), isFalse);
          expect(authorization.canAdd(module), isFalse);
          expect(authorization.canEdit(module), isFalse);
          expect(authorization.canDelete(module), isFalse);
        }
      }
    });

    test('modules without scope support always report all scope', () {
      expect(
        authenticated.scopeOf(GroupModules.employees),
        PermissionScope.all,
      );
      expect(
        authenticated.scopeOf(GroupModules.departments),
        PermissionScope.all,
      );
    });

    test('missing scope on a scoped module defaults to own', () {
      const entity = AuthorizationEntity(
        status: AuthorizationStatus.authenticated,
        uid: 'uid-1',
        employeeId: 'employee-1',
        groupId: 'group-1',
        permissions: {'attendance': GroupPermissionEntity(view: true)},
      );

      expect(entity.scopeOf(GroupModules.attendance), PermissionScope.own);
    });
  });

  group('PermissionChecker', () {
    const checker = PermissionChecker(
      AuthorizationEntity(
        status: AuthorizationStatus.authenticated,
        uid: 'uid-1',
        employeeId: 'employee-1',
        groupId: 'group-1',
        permissions: {
          'employees': _fullAccess,
          'attendance': _ownAccess,
          'payroll': GroupPermissionEntity(
            view: true,
            scope: PermissionScope.own,
          ),
          'departments': _emptyAccess,
        },
      ),
    );

    test('returns unrestricted scope for modules without scope support', () {
      final scope = checker.employeeScopeFor(GroupModules.employees);

      expect(scope.isUnrestricted, isTrue);
      expect(scope.allows('any-employee'), isTrue);
    });

    test('returns own scope restricted to the current employee', () {
      final scope = checker.employeeScopeFor(GroupModules.attendance);

      expect(scope.isOwn, isTrue);
      expect(scope.employeeId, 'employee-1');
      expect(scope.allows('employee-1'), isTrue);
      expect(scope.allows('employee-2'), isFalse);
    });

    test('returns denied scope when the module cannot be viewed', () {
      final scope = checker.employeeScopeFor(GroupModules.departments);

      expect(scope.isDenied, isTrue);
      expect(scope.allows('employee-1'), isFalse);
    });

    test('returns denied scope when own scope has no employeeId', () {
      const noEmployee = PermissionChecker(
        AuthorizationEntity(
          status: AuthorizationStatus.authenticated,
          uid: 'uid-1',
          groupId: 'group-1',
          permissions: {
            'payroll': GroupPermissionEntity(
              view: true,
              scope: PermissionScope.own,
            ),
          },
        ),
      );

      expect(noEmployee.employeeScopeFor(GroupModules.payroll).isDenied, isTrue);
    });

    test('returns all scope for scoped modules with all access', () {
      const allChecker = PermissionChecker(
        AuthorizationEntity(
          status: AuthorizationStatus.authenticated,
          uid: 'uid-1',
          employeeId: 'employee-1',
          groupId: 'group-1',
          permissions: {'payroll': _fullAccess},
        ),
      );

      expect(allChecker.employeeScopeFor(GroupModules.payroll).isUnrestricted, isTrue);
    });
  });

  group('EmployeeScope', () {
    const denied = EmployeeScope.denied();
    const unrestricted = EmployeeScope.unrestricted();
    const own = EmployeeScope.own('employee-1');

    final employees = [_employee('employee-1'), _employee('employee-2')];

    test('denied scope blocks every employee', () {
      expect(denied.allows('employee-1'), isFalse);
      expect(denied.applyToEmployees(employees), isEmpty);
    });

    test('unrestricted scope keeps every employee', () {
      expect(unrestricted.applyToEmployees(employees), hasLength(2));
    });

    test('own scope keeps only the current employee', () {
      final scoped = own.applyToEmployees(employees);

      expect(scoped, hasLength(1));
      expect(scoped.single.id, 'employee-1');
    });

    test('applyToAttendances filters by employeeId', () {
      final attendances = [
        _attendance('a-1', 'employee-1'),
        _attendance('a-2', 'employee-2'),
      ];

      expect(own.applyToAttendances(attendances), hasLength(1));
      expect(unrestricted.applyToAttendances(attendances), hasLength(2));
      expect(denied.applyToAttendances(attendances), isEmpty);
    });
  });

  group('ModuleAccess', () {
    test('denied module access is denied', () {
      const access = ModuleAccess.denied();

      expect(access.isDenied, isTrue);
      expect(access.canAdd, isFalse);
      expect(access.canEdit, isFalse);
      expect(access.canDelete, isFalse);
    });

    test('defaults to no write permissions', () {
      const access = ModuleAccess(scope: EmployeeScope.unrestricted());

      expect(access.canAdd, isFalse);
      expect(access.canEdit, isFalse);
      expect(access.canDelete, isFalse);
    });
  });
}

EmployeeEntity _employee(String id) {
  return EmployeeEntity(
    id: id,
    fullName: 'Employee $id',
    address: '',
    phoneNumber: '',
    birthDate: DateTime(1990),
    nationalId: '',
    nationality: '',
    gender: '',
    departmentId: 'dept-1',
    contractDate: DateTime(2020),
    salary: 0,
  );
}

AttendanceEntity _attendance(String id, String employeeId) {
  return AttendanceEntity(
    id: id,
    employeeId: employeeId,
    attendanceDate: DateTime(2026, 1, 1),
    status: AttendanceEntity.presentStatus,
  );
}
