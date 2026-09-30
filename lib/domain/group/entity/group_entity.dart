import 'package:hr_management_system/domain/group/entity/group_permission_entity.dart';

class GroupEntity {
  final String id;
  final String name;
  final String description;
  final List<String> employeeIds;
  final Map<String, GroupPermissionEntity> permissions;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description = '',
    this.employeeIds = const [],
    this.permissions = const {},
  });

  int get membersCount => employeeIds.length;

  GroupPermissionEntity permissionFor(String moduleKey) {
    return permissions[moduleKey] ?? const GroupPermissionEntity();
  }

  GroupEntity copyWith({
    String? name,
    String? description,
    List<String>? employeeIds,
    Map<String, GroupPermissionEntity>? permissions,
  }) {
    return GroupEntity(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      employeeIds: employeeIds ?? this.employeeIds,
      permissions: permissions ?? this.permissions,
    );
  }
}
