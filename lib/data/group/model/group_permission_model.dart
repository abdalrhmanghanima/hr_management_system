import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';

class GroupPermissionModel extends GroupPermissionEntity {
  const GroupPermissionModel({
    super.view,
    super.add,
    super.edit,
    super.delete,
    super.scope,
  });

  factory GroupPermissionModel.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const GroupPermissionModel();

    return GroupPermissionModel(
      view: (data['view'] as bool?) ?? false,
      add: (data['add'] as bool?) ?? false,
      edit: (data['edit'] as bool?) ?? false,
      delete: (data['delete'] as bool?) ?? false,
      scope: PermissionScope.fromKey(data['scope'] as String?),
    );
  }

  factory GroupPermissionModel.fromEntity(GroupPermissionEntity permission) {
    return GroupPermissionModel(
      view: permission.view,
      add: permission.add,
      edit: permission.edit,
      delete: permission.delete,
      scope: permission.scope,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'view': view,
      'add': add,
      'edit': edit,
      'delete': delete,
      'scope': scope?.key,
    };
  }
}
