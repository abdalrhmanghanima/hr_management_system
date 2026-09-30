import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_entity.dart';
import 'package:hr_management_system/domain/authorization/entity/authorization_status.dart';
import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_notifier.dart';
import 'package:hr_management_system/presentation/authorization/provider/authorization_provider.dart';

class FakeAuthorizationNotifier extends AuthorizationNotifier {
  FakeAuthorizationNotifier(this.entity);

  final AuthorizationEntity entity;

  @override
  Future<AuthorizationEntity> build() async => entity;
}

class FailingAuthorizationNotifier extends AuthorizationNotifier {
  FailingAuthorizationNotifier({this.reloadCount = 0});

  int reloadCount;

  @override
  Future<AuthorizationEntity> build() async {
    throw Exception('boom');
  }

  @override
  Future<void> reload() async {
    reloadCount++;
    state = AsyncData(buildTestAuthorization());
  }
}

const fullAccessPermission = GroupPermissionEntity(
  view: true,
  add: true,
  edit: true,
  delete: true,
  scope: PermissionScope.all,
);

const viewOnlyPermission = GroupPermissionEntity(view: true);

AuthorizationEntity buildTestAuthorization({
  String uid = 'uid-1',
  String employeeId = 'employee-1',
  String groupId = 'group-1',
  String groupName = 'HR',
  Map<GroupModule, GroupPermissionEntity> permissions = const {},
  bool fullAccess = true,
}) {
  final permissionMap = <String, GroupPermissionEntity>{};

  for (final module in GroupModules.all) {
    permissionMap[module.key] = fullAccess
        ? fullAccessPermission
        : const GroupPermissionEntity();
  }

  for (final entry in permissions.entries) {
    permissionMap[entry.key.key] = entry.value;
  }

  return AuthorizationEntity(
    status: AuthorizationStatus.authenticated,
    uid: uid,
    email: 'user@example.com',
    employeeId: employeeId,
    groupId: groupId,
    group: GroupEntity(
      id: groupId,
      name: groupName,
      description: '',
      employeeIds: [employeeId],
      permissions: permissionMap,
    ),
    permissions: permissionMap,
  );
}

AuthorizationEntity buildTestAuthorizationForStatus(
  AuthorizationStatus status, {
  String uid = 'uid-1',
  String employeeId = 'employee-1',
}) {
  return AuthorizationEntity(
    status: status,
    uid: uid,
    email: 'user@example.com',
    employeeId: status == AuthorizationStatus.missingUserDocument
        ? null
        : employeeId,
  );
}

Override fullAccessAuthorizationOverride({
  String employeeId = 'employee-1',
  String groupId = 'group-1',
}) {
  return authorizationProvider.overrideWith(
    () => FakeAuthorizationNotifier(
      buildTestAuthorization(employeeId: employeeId, groupId: groupId),
    ),
  );
}

List<Override> fullAccessAuthorizationOverrides({
  String employeeId = 'employee-1',
  String groupId = 'group-1',
}) {
  return [
    fullAccessAuthorizationOverride(
      employeeId: employeeId,
      groupId: groupId,
    ),
  ];
}
