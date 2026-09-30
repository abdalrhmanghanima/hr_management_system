import 'package:hr_management_system/domain/group/entity/group_entity.dart';
import 'package:hr_management_system/domain/group/entity/group_module.dart';
import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';
import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';

import 'authorization_status.dart';

class AuthorizationEntity {
  final AuthorizationStatus status;
  final String uid;
  final String email;
  final String? employeeId;
  final String? groupId;
  final GroupEntity? group;
  final Map<String, GroupPermissionEntity> permissions;

  const AuthorizationEntity({
    required this.status,
    required this.uid,
    this.email = '',
    this.employeeId,
    this.groupId,
    this.group,
    this.permissions = const {},
  });

  const AuthorizationEntity.loading()
    : this(status: AuthorizationStatus.loading, uid: '');

  const AuthorizationEntity.unauthenticated()
    : this(status: AuthorizationStatus.unauthenticated, uid: '');

  const AuthorizationEntity.failed()
    : this(status: AuthorizationStatus.failed, uid: '');

  bool get isResolved => status == AuthorizationStatus.authenticated;

  bool get hasGroup => group != null;

  bool get hasAnyModuleAccess => GroupModules.all.any(
    (module) => permissions[module.key]?.hasAnyGrant ?? false,
  );

  String get groupName => group?.name ?? '';

  int get membersCount => group?.membersCount ?? 0;

  GroupPermissionEntity permissionFor(GroupModule module) {
    return permissions[module.key] ?? const GroupPermissionEntity();
  }

  bool isGranted(GroupModule module, PermissionAction action) {
    if (!isResolved) return false;
    return permissionFor(module).isGranted(action);
  }

  bool canView(GroupModule module) => isGranted(module, PermissionAction.view);

  bool canAdd(GroupModule module) => isGranted(module, PermissionAction.add);

  bool canEdit(GroupModule module) => isGranted(module, PermissionAction.edit);

  bool canDelete(GroupModule module) => isGranted(module, PermissionAction.delete);

  PermissionScope scopeOf(GroupModule module) {
    if (!module.supportsScope) return PermissionScope.all;
    return permissionFor(module).scope ?? PermissionScope.own;
  }

  bool isOwnScope(GroupModule module) {
    return scopeOf(module) == PermissionScope.own;
  }

  bool isAllScope(GroupModule module) {
    return scopeOf(module) == PermissionScope.all;
  }
}
