import 'package:hr_management_system/domain/group/entity/permission_action.dart';
import 'package:hr_management_system/domain/group/entity/permission_scope.dart';

class GroupPermissionEntity {
  final bool view;
  final bool add;
  final bool edit;
  final bool delete;
  final PermissionScope? scope;

  const GroupPermissionEntity({
    this.view = false,
    this.add = false,
    this.edit = false,
    this.delete = false,
    this.scope,
  });

  bool isGranted(PermissionAction action) {
    return switch (action) {
      PermissionAction.view => view,
      PermissionAction.add => add,
      PermissionAction.edit => edit,
      PermissionAction.delete => delete,
    };
  }

  GroupPermissionEntity toggleAction(PermissionAction action) {
    return switch (action) {
      PermissionAction.view =>
        GroupPermissionEntity(
          view: !view,
          add: add,
          edit: edit,
          delete: delete,
          scope: scope,
        ),
      PermissionAction.add =>
        GroupPermissionEntity(
          view: view,
          add: !add,
          edit: edit,
          delete: delete,
          scope: scope,
        ),
      PermissionAction.edit =>
        GroupPermissionEntity(
          view: view,
          add: add,
          edit: !edit,
          delete: delete,
          scope: scope,
        ),
      PermissionAction.delete =>
        GroupPermissionEntity(
          view: view,
          add: add,
          edit: edit,
          delete: !delete,
          scope: scope,
        ),
    };
  }

  GroupPermissionEntity withScope(PermissionScope? nextScope) {
    return GroupPermissionEntity(
      view: view,
      add: add,
      edit: edit,
      delete: delete,
      scope: nextScope,
    );
  }

  bool get hasAnyGrant => view || add || edit || delete;
}
