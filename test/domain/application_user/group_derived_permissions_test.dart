import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/authorization/repository/authorization_repository_impl.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/domain/authorization/use_case/load_authorization.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserGroup({
    required String uid,
    required String employeeId,
    String? groupId,
  }) {
    throw UnimplementedError();
  }
}

class _FakeGroupRepository implements GroupRepository {
  _FakeGroupRepository(this.groups);

  final Map<String, GroupEntity> groups;

  @override
  Future<GroupEntity?> getGroupById(String id) async => groups[id];

  @override
  Future<List<GroupEntity>> getGroups() async => groups.values.toList();

  @override
  Future<GroupEntity?> getGroupByName(String name, {String? excludingId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> addGroup(GroupEntity group) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateGroup(GroupEntity group) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteGroup(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> syncEmployeeUser(String employeeId) {
    throw UnimplementedError();
  }
}

const _hrAccess = GroupPermissionEntity(
  view: true,
  add: true,
  edit: true,
  delete: true,
);

final _hrGroup = GroupEntity(
  id: 'group-hr',
  name: 'HR',
  employeeIds: const ['EMP-1'],
  permissions: {
    GroupModules.employees.key: _hrAccess,
    GroupModules.applicationUsers.key: _hrAccess,
    GroupModules.groups.key: _hrAccess,
  },
);

final _accountantGroup = GroupEntity(
  id: 'group-accountant',
  name: 'Accountant',
  employeeIds: const ['EMP-2'],
  permissions: {GroupModules.officialHolidays.key: GroupPermissionEntity(view: true)},
);

final _groups = {
  'group-hr': _hrGroup,
  'group-accountant': _accountantGroup,
};

Future<AuthorizationEntity> _authorize({
  required String email,
  required String groupId,
  String employeeId = 'EMP-1',
}) {
  return LoadAuthorization(
    AuthorizationRepositoryImpl(
      authRepo: _FakeAuthRepo(
        UserEntity(uid: 'uid-1', email: email, employeeId: employeeId, groupId: groupId),
      ),
      groupRepository: _FakeGroupRepository(_groups),
    ),
  ).call('uid-1');
}

void main() {
  group('group derived permissions', () {
    test('an HR email gets no access when its group grants none', () async {
      final result = await _authorize(
        email: 'pioneershr@gmail.com',
        groupId: 'group-accountant',
        employeeId: 'EMP-2',
      );

      expect(result.status, AuthorizationStatus.authenticated);
      expect(result.canView(GroupModules.applicationUsers), isFalse);
      expect(result.canView(GroupModules.employees), isFalse);
      expect(result.canView(GroupModules.officialHolidays), isTrue);
    });

    test('an ordinary email gets HR access when its group grants it', () async {
      final result = await _authorize(
        email: 'someone.else@example.com',
        groupId: 'group-hr',
      );

      expect(result.canView(GroupModules.applicationUsers), isTrue);
      expect(result.canEdit(GroupModules.applicationUsers), isTrue);
      expect(result.canAdd(GroupModules.employees), isTrue);
    });

    test('every email in the same group resolves the same permissions', () async {
      final first = await _authorize(
        email: 'pioneershr@gmail.com',
        groupId: 'group-hr',
      );
      final second = await _authorize(
        email: 'another.hr@pioneers.com',
        groupId: 'group-hr',
      );

      for (final module in GroupModules.all) {
        expect(second.canView(module), first.canView(module));
        expect(second.canAdd(module), first.canAdd(module));
        expect(second.canEdit(module), first.canEdit(module));
        expect(second.canDelete(module), first.canDelete(module));
      }
    });

    test('an inactive application user resolves no permissions', () async {
      final result = await LoadAuthorization(
        AuthorizationRepositoryImpl(
          authRepo: _FakeAuthRepo(
            const UserEntity(
              uid: 'uid-1',
              email: 'pioneershr@gmail.com',
              employeeId: 'EMP-1',
              groupId: 'group-hr',
              isActive: false,
            ),
          ),
          groupRepository: _FakeGroupRepository(_groups),
        ),
      ).call('uid-1');

      expect(result.status, AuthorizationStatus.inactive);

      for (final module in GroupModules.all) {
        expect(result.canView(module), isFalse);
      }
    });
  });
}
